variable "name_prefix" {
  type        = string
  description = "Prefix for the Kinesis stream name"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "ap-northeast-2"
}