terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# 기본 VPC 가져오기
data "aws_vpc" "default" {
  default = true
}

# 기본 서브넷 가져오기
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# EC2 인스턴스 생성
resource "aws_instance" "ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id     = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.mhj-sg-group.id]
  user_data              = file("user_data.sh")

  tags = merge(var.tags, { Name = local.instance_name })

  count = var.instance_count
}

resource "aws_security_group" "mhj-sg-group" {
  vpc_id = data.aws_vpc.default.id
  name = local.sg_name
  description = "EC2 Security Group - mhj"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id = aws_security_group.mhj-sg-group.id
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id = aws_security_group.mhj-sg-group.id
}

# 출력값 정의
output "public_ips" {
  value       = tolist([for instance in aws_instance.ec2 : instance.public_ip])
  description = "EC2 인스턴스의 퍼블릭 IP 주소 목록"
}

output "private_ips" {
  value       = tolist([for instance in aws_instance.ec2 : instance.private_ip])
  description = "EC2 인스턴스의 프라이빗 IP 주소 목록"
}

locals {
  instance_name = "mhj-ec2-${var.environment}"
  sg_name       = "mhj-sg-${var.environment}"
}
