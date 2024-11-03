variable "name_prefix" {
  type        = string
  description = "Prefix for naming the security group"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to create the security group in"
}
