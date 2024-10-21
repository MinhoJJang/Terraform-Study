output "bucket_arn" {
  value       = aws_s3_bucket.default.arn
  description = "The ARN of the S3 bucket."
}

output "bucket_name" {
  value = aws_s3_bucket.default.bucket
  description = "The name of the S3 bucket."
}