#!/bin/bash

# Terraform AWS Automation Deployment Script
# 🚀 Космический корабль готов к запуску!

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="terraform-automation"
AWS_REGION="eu-central-1"
REPLICA_REGION="eu-west-1"

echo -e "${BLUE}🚀 Starting Terraform AWS Automation Deployment${NC}"
echo -e "${BLUE}================================================${NC}"

# Function to print status
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_status "Prerequisites check passed ✅"
}

# Create terraform.tfvars if it doesn't exist
create_tfvars() {
    if [ ! -f "terraform.tfvars" ]; then
        print_status "Creating terraform.tfvars file..."
        
        cat > terraform.tfvars << EOF
# AWS Configuration
aws_region     = "$AWS_REGION"
replica_region = "$REPLICA_REGION"
project_name   = "$PROJECT_NAME"
environment    = "prod"

# EC2 Configuration
instance_type = "t3.micro"

# Schedule Configuration (UTC timezone)
server_start_cron = "0 7 * * MON-FRI"   # 9 AM Kiev time on weekdays
server_stop_cron  = "0 19 * * MON-FRI"  # 9 PM Kiev time on weekdays

# Feature flags
enable_versioning  = true
enable_replication = true
EOF
        print_status "terraform.tfvars created ✅"
        print_warning "Please review and update terraform.tfvars if needed"
    else
        print_status "terraform.tfvars already exists ✅"
    fi
}

# Check if SSH key is configured
check_ssh_key() {
    print_status "Checking SSH key configuration..."
    
    if grep -q "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7..." ec2.tf; then
        print_error "SSH key in ec2.tf is still the placeholder!"
        print_error "Please replace it with your actual public key."
        print_error "Generate a key with: ssh-keygen -t rsa -b 4096 -C 'your-email@example.com'"
        print_error "Then update the public_key value in ec2.tf"
        exit 1
    else
        print_status "SSH key is configured ✅"
    fi
}

# Initialize Terraform
terraform_init() {
    print_status "Initializing Terraform..."
    
    # First init with local backend
    terraform init
    
    print_status "Terraform initialized ✅"
}

# Plan deployment
terraform_plan() {
    print_status "Planning Terraform deployment..."
    
    terraform plan -out=tfplan
    
    print_status "Terraform plan completed ✅"
    print_warning "Review the plan above before proceeding"
    
    read -p "Do you want to continue with deployment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Deployment cancelled by user"
        exit 0
    fi
}

# Apply Terraform
terraform_apply() {
    print_status "Applying Terraform configuration..."
    
    terraform apply tfplan
    
    print_status "Terraform apply completed ✅"
}

# Configure remote backend
configure_backend() {
    print_status "Configuring remote backend..."
    
    # Get bucket and table names from outputs
    BUCKET_NAME=$(terraform output -raw s3_bucket_name)
    TABLE_NAME=$(terraform output -raw dynamodb_table_name)
    
    print_status "S3 Bucket: $BUCKET_NAME"
    print_status "DynamoDB Table: $TABLE_NAME"
    
    # Update backend.tf
    cat > backend.tf << EOF
terraform {
  backend "s3" {
    bucket         = "$BUCKET_NAME"
    key            = "terraform-automation/terraform.tfstate"
    region         = "$AWS_REGION"
    dynamodb_table = "$TABLE_NAME"
    encrypt        = true
  }
}
EOF
    
    print_status "Backend configuration updated ✅"
    
    # Migrate to remote backend
    print_status "Migrating state to remote backend..."
    terraform init -migrate-state -force-copy
    
    print_status "State migrated to remote backend ✅"
}

# Test deployment
test_deployment() {
    print_status "Testing deployment..."
    
    # Get instance ID
    INSTANCE_ID=$(terraform output -raw ec2_instance_id)
    
    # Check instance status
    INSTANCE_STATE=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[0].Instances[0].State.Name' \
        --output text)
    
    print_status "EC2 Instance ($INSTANCE_ID) state: $INSTANCE_STATE"
    
    # Test S3 access
    BUCKET_NAME=$(terraform output -raw s3_bucket_name)
    if aws s3 ls s3://$BUCKET_NAME/ &> /dev/null; then
        print_status "S3 bucket accessible ✅"
    else
        print_warning "S3 bucket access test failed"
    fi
    
    # Test Lambda functions
    START_FUNCTION=$(terraform output -raw lambda_start_function_arn | cut -d':' -f7)
    STOP_FUNCTION=$(terraform output -raw lambda_stop_function_arn | cut -d':' -f7)
    
    print_status "Lambda functions created:"
    print_status "  - Start function: $START_FUNCTION"
    print_status "  - Stop function: $STOP_FUNCTION"
    
    print_status "Deployment test completed ✅"
}

# Show final summary
show_summary() {
    echo
    echo -e "${GREEN}🎉 DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉${NC}"
    echo -e "${GREEN}=======================================${NC}"
    echo
    echo -e "${BLUE}📊 Deployment Summary:${NC}"
    echo
    
    # Show key outputs
    echo -e "${YELLOW}Backend Configuration:${NC}"
    echo "  S3 Bucket: $(terraform output -raw s3_bucket_name)"
    echo "  DynamoDB Table: $(terraform output -raw dynamodb_table_name)"
    echo
    
    echo -e "${YELLOW}EC2 Instance:${NC}"
    echo "  Instance ID: $(terraform output -raw ec2_instance_id)"
    echo "  Public IP: $(terraform output -raw ec2_public_ip)"
    echo
    
    echo -e "${YELLOW}Schedule:${NC}"
    echo "  Start: $(terraform output -raw start_schedule) UTC"
    echo "  Stop: $(terraform output -raw stop_schedule) UTC"
    echo
    
    echo -e "${BLUE}🚀 Next Steps:${NC}"
    echo "1. Connect to EC2: ssh ubuntu@$(terraform output -raw ec2_public_ip)"
    echo "2. Monitor Lambda logs in CloudWatch"
    echo "3. Check S3 bucket for server logs"
    echo "4. Create Pull Request with this code"
    echo
    echo -e "${GREEN}✅ Infrastructure is ready and automated!${NC}"
}

# Main deployment flow
main() {
    print_status "Starting deployment process..."
    
    check_prerequisites
    create_tfvars
    check_ssh_key
    terraform_init
    terraform_plan
    terraform_apply
    configure_backend
    test_deployment
    show_summary
    
    print_status "All done! 🚀"
}

# Run main function
main "$@"