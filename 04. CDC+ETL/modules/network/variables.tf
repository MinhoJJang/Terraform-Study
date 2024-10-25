variable "name_prefix" {
  type        = string
  description = "Prefix for naming resources"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "192.168.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet"
  default     = "192.168.1.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for the private subnet"
  default     = "192.168.2.0/24"
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-northeast-2b"]
}