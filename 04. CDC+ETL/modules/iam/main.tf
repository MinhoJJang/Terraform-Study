data "aws_caller_identity" "current" {}

resource "aws_iam_role" "dms_role" {
  name = "${var.name_prefix}-dms-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "dms.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}


resource "aws_iam_role_policy_attachment" "dms_role_policy_attachment" {
  role       = aws_iam_role.dms_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


resource "aws_iam_role" "firehose_role" {
  name = "${var.name_prefix}-firehose-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"

      Principal = {
        Service = "firehose.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""

    }]
  })
}


resource "aws_iam_role_policy_attachment" "firehose_role_policy_attachment" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

}