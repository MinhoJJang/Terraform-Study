variable "name_prefix" {
  type        = string
  description = "Prefix for the DMS endpoint identifiers"
}

variable "rds_endpoint" {
  type        = string
  description = "The endpoint of the RDS instance"
}

variable "rds_port" {
  type        = number
  description = "The port of the RDS instance"
}

variable "rds_username" {
  type        = string
  description = "The username for the RDS instance"
}

variable "rds_password" {
  type        = string
  sensitive   = true
  description = "The password for the RDS instance"
}

variable "kinesis_stream_arn" {
  type        = string
  description = "The ARN of the Kinesis stream"
}

variable "dms_role_arn" {
  type        = string
  description = "The ARN of the IAM role with Kinesis access for DMS"
}
