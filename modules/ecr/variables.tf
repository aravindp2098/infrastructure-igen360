variable "project" {
  description = "Project name used in resource naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "repository_names" {
  description = "ECR repository short names to create."
  type        = list(string)
  default     = ["app"]
}

variable "image_tag_mutability" {
  description = "Image tag mutability for ECR repositories."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable ECR image scanning when images are pushed."
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Allow Terraform destroy to delete repositories that contain images. Keep false in prod."
  type        = bool
  default     = false
}

variable "max_image_count" {
  description = "Maximum number of images to retain per repository."
  type        = number
  default     = 100
}

variable "tags" {
  description = "Additional tags applied to all ECR resources."
  type        = map(string)
  default     = {}
}
