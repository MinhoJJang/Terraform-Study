resource "aws_iam_role" "dms_vpc_role" {
  name = "dms-vpc-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "dms.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "dms_vpc_role_policy" {
  role       = aws_iam_role.dms_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

resource "aws_dms_replication_subnet_group" "dms_subnet_group" {

  replication_subnet_group_id          = "${var.name_prefix}-dms-subnet-group"
  replication_subnet_group_description = "DMS subnet group"
  subnet_ids                           = var.subnet_ids

  depends_on = [aws_iam_role_policy_attachment.dms_vpc_role_policy]
}