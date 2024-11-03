variable "name_prefix" {
  type        = string
  description = "Prefix for the RDS instance identifier"
}

variable "username" {
  type        = string
  description = "Master username for the RDS instance"
}

variable "password" {
  type        = string
  sensitive   = true
  description = "Master password for the RDS instance"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of IDs of public subnets"
}