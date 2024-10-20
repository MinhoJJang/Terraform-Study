data "aws_vpc" "default" {
 default = true
}


resource "aws_security_group" "default" {
 name        = "${var.name_prefix}-dms-sg"
 description = "Allow inbound traffic for DMS"
 vpc_id      = data.aws_vpc.default.id # Use default VPC

 # Add ingress rules as needed for your DMS setup (e.g., for source and target endpoints)
 # Example: allow all outbound traffic
 egress {
   from_port        = 0
   to_port          = 0
   protocol         = "-1"
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
 }
}
