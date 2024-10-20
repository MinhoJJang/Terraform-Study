resource "aws_dms_replication_instance" "default" {
  allocated_storage            = var.allocated_storage
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  engine_version               = "3.5.2" # or latest
  multi_az                     = false # You can change this if needed
  preferred_maintenance_window = "sun:10:30-sun:14:30" # Customize as needed
  publicly_accessible          = false #  You can change this if needed
  replication_instance_class   = var.replication_instance_class
  replication_instance_id      = "${var.name_prefix}-dms-replication-instance"
  replication_subnet_group_id  = var.replication_subnet_group_id
  vpc_security_group_ids      = var.vpc_security_group_ids

}