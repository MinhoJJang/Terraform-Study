resource "aws_dms_replication_task" "default" {
  migration_type            = var.migration_type
  replication_instance_arn  = var.replication_instance_arn
  replication_task_id       = "${var.name_prefix}-dms-replication-task"
  replication_task_settings = var.replication_task_settings
  source_endpoint_arn       = var.source_endpoint_arn
  table_mappings            = var.table_mappings
  target_endpoint_arn       = var.target_endpoint_arn
  start_replication_task    = var.start_replication_task

  tags = {
    Name = var.name_prefix
  }
}