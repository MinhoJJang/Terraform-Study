variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
}

variable "force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the bucket."
  default     = {}
}


variable "versioning_enabled" {
  type        = bool
  description = "Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state. You can, however, suspend versioning on that bucket."
  default     = true
}