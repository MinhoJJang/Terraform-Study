variable "name_prefix" {
  type        = string
  description = "Prefix for naming the DMS instance"
}

variable "engine_version" {
  type        = string
  description = "The engine version of the DMS instance"
  default     = "3.5.2"
}

variable "replication_subnet_group_id" {
  type        = string
  description = "The ID of the replication subnet group"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of VPC security group IDs"
}

variable "preferred_maintenance_window" {
  type        = string
  description = "The preferred maintenance window"
  default     = "sun:10:30-sun:14:30"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "instance_class" {
  type    = string
  default = "dms.t2.micro"
}