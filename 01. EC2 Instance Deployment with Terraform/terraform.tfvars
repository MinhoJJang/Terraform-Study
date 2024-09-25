region = "ap-northeast-2"
project_name = "terraform_project"
target_label = "dev"


### VPC variables
vpc_cidr = "172.100.0.0/16"
public_cidr = ["172.100.0.0/24"]
azs = ["ap-northeast-2a"]


### EC2 variables
ec2_instance_spec = "t2.micro"