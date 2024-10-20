output "dms_full_access_role_arn" {
 value = aws_iam_role.dms_full_access_role.arn
}

output "dms_vpc_role_arn" { # New output
 value = aws_iam_role.dms_vpc_role.arn
}

output "dms_cloudwatch_logs_role_arn" { # New output
 value = aws_iam_role.dms_cloudwatch_logs_role.arn
}