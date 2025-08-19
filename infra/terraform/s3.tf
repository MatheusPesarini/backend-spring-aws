resource "random_id" "suffix" {
  byte_length = 3
}

locals {
  s3_app_bucket_name      = coalesce(var.s3_bucket, lower("${var.project_name}-${var.environment}-data-${random_id.suffix.hex}"))
  s3_artifact_bucket_name = coalesce(var.artifact_bucket, lower("${var.project_name}-${var.environment}-artifact-${random_id.suffix.hex}"))
}

resource "aws_s3_bucket" "app" {
  bucket = local.s3_app_bucket_name
  force_destroy = true
  tags = {
    Name        = local.s3_app_bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "artifact" {
  bucket = local.s3_artifact_bucket_name
  force_destroy = true
  tags = {
    Name        = local.s3_artifact_bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "artifact" {
  bucket = aws_s3_bucket.artifact.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifact" {
  bucket = aws_s3_bucket.artifact.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifact" {
  bucket = aws_s3_bucket.artifact.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

