variable "project" {
  description = "Project name used in resource naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "vpc_id" {
  description = "VPC where ECS and ALB resources are created."
  type        = string
}

variable "alb_subnet_ids" {
  description = "Subnet IDs for the internal application load balancer (private subnets in prod)."
  type        = list(string)
}

variable "service_subnet_ids" {
  description = "Private subnet IDs where Fargate tasks run."
  type        = list(string)
}

variable "container_image" {
  description = "Full container image URI for the ECS task."
  type        = string
}

variable "container_port" {
  description = "Container port exposed by the application."
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "HTTP path used by the ALB target group health check."
  type        = string
  default     = "/"
}

variable "desired_count" {
  description = "Desired number of ECS tasks."
  type        = number
  default     = 2
}

variable "cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 1024
}

variable "memory" {
  description = "Fargate task memory in MiB."
  type        = number
  default     = 2048
}

variable "assign_public_ip" {
  description = "Assign public IPs to Fargate tasks. Must stay false in prod."
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "Additional CIDR blocks allowed to reach the ALB. Empty by default — prod fronts the ALB with CloudFront only. Must never be 0.0.0.0/0."
  type        = list(string)
  default     = []

  validation {
    condition     = !contains(var.allowed_cidr_blocks, "0.0.0.0/0")
    error_message = "The ALB must not be open to 0.0.0.0/0. Front it with CloudFront (allow_cloudfront_vpc_origin) instead."
  }
}

variable "allow_cloudfront_vpc_origin" {
  description = "Allow CloudFront VPC origins to reach the internal ALB on port 80."
  type        = bool
  default     = true
}

variable "environment_variables" {
  description = "Plain text environment variables for the application container."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets exposed to the container. Map keys are env var names and values are Secrets Manager or SSM parameter ARNs."
  type        = map(string)
  default     = {}
}

variable "log_retention_in_days" {
  description = "CloudWatch Logs retention for ECS task logs."
  type        = number
  default     = 90
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for the service. Keep false in prod."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to all ECS resources."
  type        = map(string)
  default     = {}
}
