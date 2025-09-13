# Primary S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-state-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.environment
    Purpose     = "Terraform Backend"
  }
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "terraform_state_pab" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Replica S3 bucket in different region
resource "aws_s3_bucket" "terraform_state_replica" {
  count    = var.enable_replication ? 1 : 0
  provider = aws.replica
  bucket   = "${var.project_name}-state-replica-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "Terraform State Replica Bucket"
    Environment = var.environment
    Purpose     = "Terraform Backend Replica"
  }
}

# Replica bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state_replica_versioning" {
  count    = var.enable_replication ? 1 : 0
  provider = aws.replica
  bucket   = aws_s3_bucket.terraform_state_replica[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket replication configuration
resource "aws_s3_bucket_replication_configuration" "terraform_state_replication" {
  count  = var.enable_replication ? 1 : 0
  bucket = aws_s3_bucket.terraform_state.id
  role   = aws_iam_role.replication_role[0].arn

  rule {
    id     = "replicate-all"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.terraform_state_replica[0].arn
      storage_class = "STANDARD_IA"
    }
  }

  depends_on = [aws_s3_bucket_versioning.terraform_state_versioning]
}

# S3 bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_lifecycle" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "noncurrent-version-lifecycle"
    status = "Enabled"

    filter {} # обязательный пустой фильтр

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }

  rule {
    id     = "move-to-ia"
    status = "Enabled"

    filter {} # обязательный пустой фильтр

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}