name_prefix  = "minho"
rds_username = "root"
rds_password = "cloudclub6"

vpc_cidr = "192.168.0.0/16"
public_subnets = {
  subnet1 = {
    cidr_block        = "192.168.1.0/24"
    availability_zone = "ap-northeast-2b"
  }
  subnet2 = {
    cidr_block        = "192.168.3.0/24"
    availability_zone = "ap-northeast-2c"
  }
}

private_subnets = {
  subnet1 = {
    cidr_block        = "192.168.2.0/24"
    availability_zone = "ap-northeast-2b"
  }
  subnet2 = {
    cidr_block        = "192.168.4.0/24"
    availability_zone = "ap-northeast-2c"
  }
}