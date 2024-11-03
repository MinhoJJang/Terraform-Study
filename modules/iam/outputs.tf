output "dms_role_arn" {
  value = aws_iam_role.dms_role.arn
}

output "firehose_role_arn" {
  value = aws_iam_role.firehose_role.arn
}