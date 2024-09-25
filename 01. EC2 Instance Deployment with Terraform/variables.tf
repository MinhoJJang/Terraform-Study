variable "region" {
  description = "aws region"
  type = string
  default = "ap-northeast-2"
}

variable "project_name" {
  description = "project name"
  type = string
  default = null
}

variable "target_label" {
  description = "dev/stage/prod"
  type = string
  default = null
}

variable "vpc_cidr" {
  description = "VPC CIDR Range"
  type = string
  default = null
}

variable "azs" {
    description = "A list of availability zones names or ids in the region"
    type = list(string)
    default = ["ap-northeast-2a"]
  
}

variable "public_cidr" {
  description = "Public Subnet CIDR"
  type = list(string)
  default = null
}

variable "ec2_instance_spec" {
  description = "EC2 Spec Information"
  type = string
  default = null
}