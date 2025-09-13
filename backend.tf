# Backend will be configured after creating S3 and DynamoDB
terraform {
  backend "s3" {
    bucket         = "terraform-automation-state-5fba147833d48a75"
    key            = "terraform-automation/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-automation-locks"
    encrypt        = true
  }
}
