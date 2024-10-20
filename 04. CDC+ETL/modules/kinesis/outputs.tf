output "stream_arn" {
  value       = aws_kinesis_stream.default.arn
  description = "The ARN of the Kinesis stream"
}

output "stream_name" {
  value = aws_kinesis_stream.default.name
  description = "The name of the Kinesis stream"
}
