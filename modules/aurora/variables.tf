variable "project" {
  description = "Project name, used for resource naming."
  type        = string
}

variable "environment" {
  description = "Environment name (prod)."
  type        = string
}

variable "db_subnet_group_name" {
  description = "DB subnet group (private subnets) for the Aurora cluster."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Security group IDs attached to the Aurora cluster."
  type        = list(string)
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version."
  type        = string
  default     = "16.4"
}

variable "database_name" {
  description = "Name of the initial application database."
  type        = string
}

variable "master_username" {
  description = "Master username for the Aurora cluster."
  type        = string
  default     = "qmetry_admin"
}

variable "master_password" {
  description = "Master password (sourced from Secrets Manager module)."
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Instance class for cluster instances."
  type        = string
  default     = "db.r6g.large"
}

variable "instance_count" {
  description = "Number of cluster instances. Prod should use >= 2 for Multi-AZ."
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count >= 1
    error_message = "instance_count must be at least 1."
  }
}

variable "backup_retention_period" {
  description = "Automated backup retention in days."
  type        = number
  default     = 30
}

variable "preferred_backup_window" {
  description = "Daily backup window (UTC)."
  type        = string
  default     = "02:00-03:00"
}

variable "deletion_protection" {
  description = "Protect the cluster from deletion. Must stay true in prod."
  type        = bool
  default     = true
}

variable "storage_encrypted" {
  description = "Encrypt cluster storage at rest."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "Optional KMS key ARN for storage encryption. When null, the default RDS key is used."
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy. Must stay false in prod."
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply modifications immediately rather than in the maintenance window."
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Enable RDS Performance Insights on cluster instances."
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0 disables)."
  type        = number
  default     = 60
}

variable "port" {
  description = "Database port."
  type        = number
  default     = 5432
}

variable "tags" {
  description = "Additional tags to apply."
  type        = map(string)
  default     = {}
}
