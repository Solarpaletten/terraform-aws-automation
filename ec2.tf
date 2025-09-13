# Data source for latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group for EC2 instance
resource "aws_security_group" "ec2_sg" {
  name_prefix = "${var.project_name}-ec2-"
  description = "Security group for auto-managed EC2 instance"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-ec2-sg"
    Environment = var.environment
  }
}

# EC2 Key Pair (you'll need to provide your public key)
resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.project_name}-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCgV1SPd51cCDcijaW0z9vUOWA1VzSh9skRmt5RU59FcKKUnazF7yAvwL/YH+RbWvdUIJr7ccueoQzpbvWOX3SQQwGkkgJKQUtM/ceP6ULETxdMNRNitDmSWdT+lnmQsNbU1lAp+w69Z/4VZvoTZKEgg21zqx9207YrwmXWW4eUJg35kWV7YhPVr8gCkH0l7txN3hRoaIUEjVbfUZprf5q4SbWOWB4coJGW+kKkdR2c+8jDoNF350Bm6wutC4UWCuzVtC+89nc6JY0OrcvYC9o1qXHLv/i0Es/zi8cAwc+nY2sOBNhMbhdwx1hVmZk5jN/s7GgL6bVNsM+4DHwddWcYIlPZqHVu5m8Y9SPcw2bWl5fNFZO9DkEfbK6BtbUZi4h94yEZ2Yu1o4/rZCQU1/a09oddXcWC2FPzvWOqv9CaF+s5TtMCo7XHb++YBgAE8371m/OHTBoO76MOXyT7hN4Joe9jauPqZ1GgcCXXd3lFGAS7OcDvrGZtyYThxAAKWdJBNR73j9bw4KjadSgaarRwbVTtOPIj7MDQHE7+Cj4cbd2wwv6mMmBr8B36zV0oiu0h81CJ7WrL3T2F4ROs+YkOqfgouNqM9IePFXSDTwvjLv8EdVD4xQnSpTpMvSxm07ogTTuOcE93jAlYO0BSa5i/e4VDkmhx/p/+43tuun4M5w== solarpaletten@gmail.com"


  tags = {
    Name        = "${var.project_name} SSH Key"
    Environment = var.environment
  }
}

# EC2 Instance
resource "aws_instance" "auto_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ec2_key.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    bucket_name = aws_s3_bucket.terraform_state.bucket
  }))

  tags = {
    Name         = "${var.project_name}-auto-server"
    Environment  = var.environment
    AutoStart    = "true"
    AutoStop     = "true"
    ScheduleType = "lambda"
  }
}

# Lambda function for starting instances
resource "aws_lambda_function" "start_instances" {
  filename      = "start_instances.zip"
  function_name = "${var.project_name}-start-instances"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 60

  source_code_hash = data.archive_file.start_instances_zip.output_base64sha256

  environment {
    variables = {
      REGION = var.aws_region
    }
  }

  tags = {
    Name        = "Start EC2 Instances"
    Environment = var.environment
  }
}

# Lambda function for stopping instances
resource "aws_lambda_function" "stop_instances" {
  filename      = "stop_instances.zip"
  function_name = "${var.project_name}-stop-instances"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 60

  source_code_hash = data.archive_file.stop_instances_zip.output_base64sha256

  environment {
    variables = {
      REGION = var.aws_region
    }
  }

  tags = {
    Name        = "Stop EC2 Instances"
    Environment = var.environment
  }
}

# EventBridge rule for starting instances
resource "aws_cloudwatch_event_rule" "start_instances" {
  name                = "${var.project_name}-start-instances"
  description         = "Start EC2 instances on schedule"
  schedule_expression = var.server_start_cron

  tags = {
    Name        = "Start Instances Schedule"
    Environment = var.environment
  }
}

# EventBridge rule for stopping instances  
resource "aws_cloudwatch_event_rule" "stop_instances" {
  name                = "${var.project_name}-stop-instances"
  description         = "Stop EC2 instances on schedule"
  schedule_expression = var.server_stop_cron

  tags = {
    Name        = "Stop Instances Schedule"
    Environment = var.environment
  }
}

# EventBridge target for start function
resource "aws_cloudwatch_event_target" "start_instances" {
  rule      = aws_cloudwatch_event_rule.start_instances.name
  target_id = "StartInstancesTarget"
  arn       = aws_lambda_function.start_instances.arn
}

# EventBridge target for stop function
resource "aws_cloudwatch_event_target" "stop_instances" {
  rule      = aws_cloudwatch_event_rule.stop_instances.name
  target_id = "StopInstancesTarget"
  arn       = aws_lambda_function.stop_instances.arn
}

# Lambda permissions for EventBridge
resource "aws_lambda_permission" "allow_eventbridge_start" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_instances.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_instances.arn
}

resource "aws_lambda_permission" "allow_eventbridge_stop" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_instances.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_instances.arn
}