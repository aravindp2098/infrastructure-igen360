variable "project" {
  description = "Project name used in resource naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "bucket_name" {
  description = "Optional S3 bucket name. Defaults to {project}-{environment}-frontend-{account_id}."
  type        = string
  default     = null
}

variable "enable_versioning" {
  description = "Enable S3 object versioning on the bucket."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
