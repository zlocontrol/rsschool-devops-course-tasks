# Generate a random string to make S3 bucket name unique
resource "random_id" "unique_suffix" {
  byte_length = 8 # 8 bytes will generate a 16-character string
}

# Create an S3 bucket to store Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket              = "${var.s3_bucket_name}-${random_id.unique_suffix.hex}"
  force_destroy       = false
  object_lock_enabled = false


  tags = merge(module.label.tags, {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  })
}

# Enable versioning on the bucket
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}


