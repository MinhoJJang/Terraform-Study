module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.project_name}-${var.target_label}-vpc"

  # vpc cidr 설정
  cidr = var.vpc_cidr

  # VPC 가용영역 설정
  azs = var.azs

  # subnet cidr 설정
  public_subnets = var.public_cidr

  # public ip를 매핑할 것인지 여부
  map_public_ip_on_launch = true

  # 자동으로 인터넷 게이트웨이를 생성하도록 설정
  create_igw = true
}