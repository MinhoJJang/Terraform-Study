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

resource "aws_db_parameter_group" "default" {
  name   = "${var.name_prefix}-mysql-parameter-group"
  family = "mysql8.0"

  parameter {
    name         = "binlog_format"
    value        = "ROW"
    apply_method = "immediate"
  }
}


resource "aws_db_instance" "default" {

  allocated_storage    = 20 
  engine               = "mysql"
  engine_version       = "8.0" 
  instance_class       = "db.t3.micro" 
  username             = var.username
  password             = var.password
  db_subnet_group_name = aws_db_subnet_group.default.name
  parameter_group_name = aws_db_parameter_group.default.name
  backup_retention_period = 7
  skip_final_snapshot  = true
  identifier           = "${var.name_prefix}-mysql-instance"
  publicly_accessible = true
}


resource "aws_db_subnet_group" "default" {
  name       = "${var.name_prefix}-mysql-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "${var.name_prefix}-mysql-subnet-group"
  }
}
