variable "region" {
  type        = string
  description = "AWS 리전"
  default     = "ap-northeast-2"
}

variable "ami" {
  type        = string
  description = "EC2 AMI ID"
}

variable "instance_type" {
  type        = string
  description = "EC2 인스턴스 유형"
  default = "t2.micro"
}

variable "tags" {
  type = map(string)
  description = "EC2 태그"
  default = {
    Environment = "dev"
  }
}

variable "instance_count" {
  type = number
  default = 1
}

variable "environment" {
  type = string
  default = "dev"
}

