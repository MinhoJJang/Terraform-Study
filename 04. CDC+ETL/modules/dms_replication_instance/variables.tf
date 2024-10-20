
variable "name_prefix" {
  type = string
}

variable "replication_instance_class" {
  type = string
}

variable "allocated_storage" {
 type = number
}

variable "replication_subnet_group_id" {
 type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}