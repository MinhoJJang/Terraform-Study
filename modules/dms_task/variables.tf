variable "name_prefix" {
  type        = string
  description = "Prefix for naming the DMS task"
}

variable "replication_instance_arn" {
  type        = string
  description = "ARN of the DMS replication instance"
}

variable "source_endpoint_arn" {
  type        = string
  description = "ARN of the source endpoint"
}

variable "target_endpoint_arn" {
  type        = string
  description = "ARN of the target endpoint"
}

variable "migration_type" {
  type        = string
  description = "Migration type. Can be one of full-load | cdc | full-load-and-cdc"
  default     = "cdc"

}

variable "table_mappings" {
  type        = string
  description = "JSON string containing the table mappings"
}

variable "replication_task_settings" {
  type        = string
  description = "(Optional) JSON string containing task settings"
  default     = "{}"
}

variable "start_replication_task" {
  type        = bool
  description = "Whether to start the replication task immediately after creation"
  default     = true
}
