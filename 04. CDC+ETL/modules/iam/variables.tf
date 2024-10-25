variable "name_prefix" {
  type        = string
  description = "Prefix for the IAM role name"
}

variable "kinesis_stream_arn" {
  type        = string
  description = "The ARN of the Kinesis stream"
}
