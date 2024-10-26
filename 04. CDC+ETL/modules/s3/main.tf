resource "aws_s3_bucket" "default" {
  bucket        = "${var.name_prefix}-cdc-s3"
  force_destroy = true
}
