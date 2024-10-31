resource "aws_s3_bucket" "s3_bucket" {
  bucket = uuid() # Generates a UUID for the bucket name

  # Ensure Terraform can delete the bucket even if not empty
  force_destroy = true
}


//Set default encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Using AES256 encryption
    }
  }
}


resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true # Block public ACLs
  ignore_public_acls      = true # Ignore public ACLs
  block_public_policy     = true # Block public policies
  restrict_public_buckets = true # Restrict public bucket policies
}

//Set lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    id     = "TransitionToStandardIA"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

