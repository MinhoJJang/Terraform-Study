resource "aws_kinesis_stream" "default" {
  name = "${var.name_prefix}-kinesis-stream"

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }
}