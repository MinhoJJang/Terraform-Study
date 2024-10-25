variable "name_prefix" {
  type        = string
  description = "A prefix name of the resources"
}

variable "s3_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket where Firehose will deliver data."
}

variable "kinesis_stream_arn" {
  type        = string
  description = "The ARN of the Kinesis stream as the data source."
}

