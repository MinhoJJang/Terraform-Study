resource "aws_db_parameter_group" "default" {
  name   = "${var.name_prefix}-mysql-parameter-group"
  family = "mysql8.0"

  parameter {
    name         = "binlog_format"
    value        = "ROW"
    apply_method = "immediate"
  }

  parameter {
    apply_method = "immediate"
    name         = "binlog_checksum"
    value        = "NONE"
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.name_prefix}-rds-sg"
  description = "Allow inbound traffic on port 3306"
  ingress {
    description = "Allow MySQL access from anywhere"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}


resource "aws_db_instance" "default" {

  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = var.username
  password                = var.password
  db_subnet_group_name    = aws_db_subnet_group.default.name
  parameter_group_name    = aws_db_parameter_group.default.name
  backup_retention_period = 7
  skip_final_snapshot     = true
  identifier              = "${var.name_prefix}-mysql-instance"
  publicly_accessible     = true
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

}

resource "aws_db_subnet_group" "default" {
  name       = "${var.name_prefix}-mysql-subnet-group"
  subnet_ids = var.public_subnet_ids
  tags = {
    Name = "${var.name_prefix}-mysql-subnet-group"
  }
}
