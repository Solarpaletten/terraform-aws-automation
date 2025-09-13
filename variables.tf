variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "replica_region" {
  description = "Replica AWS region for S3 replication"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "terraform-automation"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "server_start_cron" {
  description = "Cron expression for server start (AWS format)"
  type        = string
  default     = "cron(0 7 ? * MON-FRI *)"
}

variable "server_stop_cron" {
  description = "Cron expression for server stop (AWS format)"
  type        = string
  default     = "cron(0 19 ? * MON-FRI *)"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "enable_replication" {
  description = "Enable cross-region replication"
  type        = bool
  default     = true
}