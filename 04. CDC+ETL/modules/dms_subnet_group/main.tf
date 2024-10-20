data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


resource "aws_dms_replication_subnet_group" "default" {
  replication_subnet_group_id          = "${var.name_prefix}-dms-replication-subnet-group"
  replication_subnet_group_description = "DMS replication subnet group"
 subnet_ids                           = data.aws_subnets.default.ids # Use default VPC subnets
}
