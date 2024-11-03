resource "aws_kinesis_firehose_delivery_stream" "default" {
  name        = "${var.name_prefix}-firehose-delivery-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = var.firehose_role_arn
    bucket_arn          = var.s3_bucket_arn
    compression_format  = "UNCOMPRESSED"
    prefix              = "${var.name_prefix}-prefix/"
    error_output_prefix = "${var.name_prefix}-error-prefix/"
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/${var.name_prefix}-firehose-delivery-stream"
      log_stream_name = "error-stream"
    }
  }

  kinesis_source_configuration {
    kinesis_stream_arn = var.kinesis_stream_arn
    role_arn           = var.firehose_role_arn
  }
}
