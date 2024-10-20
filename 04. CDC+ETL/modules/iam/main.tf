resource "aws_iam_role" "dms_full_access_role" {
  name = "${var.name_prefix}-dms-full-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "dms.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "dms_full_access_policy" {
  name = "${var.name_prefix}-dms-full-access-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "rds:*",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "kinesis:*",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "s3:*",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [ "dms:*"],
        Resource = "*"  
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dms_full_access_attachment" {
  role       = aws_iam_role.dms_full_access_role.name
  policy_arn = aws_iam_policy.dms_full_access_policy.arn
}




# Roles for VPC and CloudWatch Logs (still needed by DMS Replication Instance)
resource "aws_iam_role" "dms_vpc_role" {  # New role
  name               = "${var.name_prefix}-dms-vpc-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "dms.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "dms_vpc_role_attachment" {
 role       = aws_iam_role.dms_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

resource "aws_iam_role" "dms_cloudwatch_logs_role" { # New role
 name               = "${var.name_prefix}-dms-cloudwatch-logs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
 {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
 Service = "dms.amazonaws.com"
 }
 }
 ]
 })
}


resource "aws_iam_role_policy_attachment" "dms_cloudwatch_logs_role_attachment" { # New policy attachment
  role       = aws_iam_role.dms_cloudwatch_logs_role.name
 policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}
