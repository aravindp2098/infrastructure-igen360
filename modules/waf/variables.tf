variable "project" {
  description = "Project name used in resource naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "rate_limit" {
  description = "Max requests allowed from a single IP over a 5-minute window before blocking."
  type        = number
  default     = 2000
}

variable "enable_managed_rules" {
  description = "Attach AWS managed rule groups (common, known bad inputs, SQLi)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to all WAF resources."
  type        = map(string)
  default     = {}
}
