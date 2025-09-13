# Backend configuration outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "s3_replica_bucket_name" {
  description = "Name of the S3 replica bucket"
  value       = var.enable_replication ? aws_s3_bucket.terraform_state_replica[0].bucket : null
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.arn
}

# EC2 outputs
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.auto_server.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.auto_server.public_ip
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.auto_server.private_ip
}

# Lambda outputs
output "lambda_start_function_arn" {
  description = "ARN of the Lambda function for starting instances"
  value       = aws_lambda_function.start_instances.arn
}

output "lambda_stop_function_arn" {
  description = "ARN of the Lambda function for stopping instances"
  value       = aws_lambda_function.stop_instances.arn
}

# Schedule outputs
output "start_schedule" {
  description = "Cron expression for starting instances"
  value       = var.server_start_cron
}

output "stop_schedule" {
  description = "Cron expression for stopping instances"
  value       = var.server_stop_cron
}

# Backend configuration for migration
output "backend_config" {
  description = "Backend configuration for terraform init"
  value = {
    bucket         = aws_s3_bucket.terraform_state.bucket
    key            = "terraform-automation/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
    encrypt        = true
  }
}