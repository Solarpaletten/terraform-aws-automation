# Generate random ID for unique resource naming
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# Generate random password for potential future use
resource "random_password" "server_password" {
  length  = 16
  special = true
}