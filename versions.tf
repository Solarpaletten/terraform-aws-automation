terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Primary region provider
provider "aws" {
  region = var.aws_region
}

# Replica region provider for S3 cross-region replication
provider "aws" {
  alias  = "replica"
  region = var.replica_region
}