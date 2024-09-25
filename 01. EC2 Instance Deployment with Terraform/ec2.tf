resource "aws_instance" "ec2_instance" {
  ami = "ami-05d2438ca66594916"
  instance_type = "${var.ec2_instance_spec}"

  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.terraform-ec2-sg.id]

  associate_public_ip_address = true

  # 키 페어는 사용하지 않으므로, 설정 안함
  # key_name = aws_key_pair.example_key_pair.key_name

  # 인스턴스가 시작될 때 실행할 사용자 데이터
  # 인스턴스가 시작될 때 실행되는 스크립트 코드
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install nginx -y
  EOF

  tags = {
    Name = "${var.project_name}-${var.target_label}-ec2"
  }
}

# resource "aws_key_pair" "example_key_pair" {
#   key_name = "example_key"
#   public_key = file("key-path/rsa.pub")
# }