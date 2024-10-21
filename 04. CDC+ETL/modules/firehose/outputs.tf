output "firehose_arn" {
  value = aws_kinesis_firehose_delivery_stream.default.arn
  description = "The ARN of the Firehose delivery stream."
}