variable "name_prefix" {
  type = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to include in the subnet group"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the subnet group should be created"
}