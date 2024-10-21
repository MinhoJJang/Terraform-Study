resource "aws_s3_bucket" "default" {
  bucket = var.bucket_name
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "default" {
  bucket = aws_s3_bucket.default.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended" # Set to "Suspended" if you don't need versioning
  }
}