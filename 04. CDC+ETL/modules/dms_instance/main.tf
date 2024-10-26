resource "aws_dms_replication_instance" "default" {
  allocated_storage            = var.allocated_storage
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  engine_version               = var.engine_version
  multi_az                     = false
  preferred_maintenance_window = var.preferred_maintenance_window
  publicly_accessible          = true
  replication_instance_class   = var.instance_class
  replication_instance_id      = "${var.name_prefix}-dms-replication-instance"
  replication_subnet_group_id  = var.replication_subnet_group_id
  vpc_security_group_ids       = var.vpc_security_group_ids
  allow_major_version_upgrade  = false

  tags = {
    Name = var.name_prefix
  }
}