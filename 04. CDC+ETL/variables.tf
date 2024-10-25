variable "name_prefix" {
  type = string
}

variable "rds_username" {
  type    = string
  default = "admin"
}

variable "rds_password" {
  type      = string
  sensitive = true
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "public_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "private_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}