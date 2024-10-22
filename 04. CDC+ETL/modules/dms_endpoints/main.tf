resource "aws_dms_endpoint" "source" {
  endpoint_id                 = "${var.name_prefix}-rds-source-endpoint"
  endpoint_type               = "source"
  engine_name                 = "mysql"
  server_name                 = var.rds_endpoint
  port                        = var.rds_port
  username                    = var.rds_username
  password                    = var.rds_password
  database_name               = var.rds_database_name
  ssl_mode                    = "none" 
}

resource "aws_dms_endpoint" "target" {
  endpoint_id       = "${var.name_prefix}-kinesis-target-endpoint"
  endpoint_type     = "target"
  engine_name       = "kinesis"
  kinesis_settings {
    stream_arn = var.kinesis_stream_arn
    service_access_role_arn = var.dms_kinesis_access_role_arn
    message_format = "json" 
  }
}