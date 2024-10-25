
data "aws_caller_identity" "current" {}


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

resource "aws_iam_role_policy" "firehose_policy" {
  name = "${var.name_prefix}-firehose-policy"
  role = aws_iam_role.firehose_role.id


  policy = templatefile("${path.module}/firehose_policy.json", {
    account_id          = data.aws_caller_identity.current.account_id
    region              = data.aws_caller_identity.current.account_id
    s3_bucket_name      = "${var.name_prefix}-cdc-s3-bucket"
    kinesis_stream_arn  = var.kinesis_stream_arn
    kinesis_stream_name = replace(var.kinesis_stream_arn, "arn:aws:kinesis:.+?:(.+?):stream/(.+)", "$2")
  })
}



resource "aws_kinesis_firehose_delivery_stream" "default" {
  name        = "${var.name_prefix}-firehose-delivery-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role.arn
    bucket_arn          = var.s3_bucket_arn
    compression_format  = "UNCOMPRESSED"
    prefix              = "my-prefix/"
    error_output_prefix = "error-prefix/"


  }



  kinesis_source_configuration {
    kinesis_stream_arn = var.kinesis_stream_arn
    role_arn           = aws_iam_role.firehose_role.arn
  }
}
