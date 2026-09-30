variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "name" {
  description = "Secret name suffix (e.g. aurora-master)."
  type        = string
}

variable "username" {
  description = "Database username stored in the secret."
  type        = string
}

variable "password" {
  description = "Optional existing master password. When null, a strong random password is generated."
  type        = string
  default     = null
  sensitive   = true
}

variable "engine" {
  description = "Database engine identifier stored in the secret."
  type        = string
  default     = "aurora-postgresql"
}

variable "dbname" {
  description = "Database name stored in the secret."
  type        = string
}

variable "recovery_window_in_days" {
  description = "Secrets Manager recovery window. Defaults to 30 for prod."
  type        = number
  default     = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
