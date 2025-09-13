# AWS Configuration
aws_region     = "eu-central-1"
replica_region = "eu-west-1"
project_name   = "terraform-automation"
environment    = "prod"

# EC2 Configuration
instance_type = "t3.micro"

# Schedule Configuration (UTC timezone)
server_start_cron = "cron(0 7 ? * MON-FRI *)"
server_stop_cron  = "cron(0 19 ? * MON-FRI *)"

# Feature flags
enable_versioning  = true
enable_replication = true
