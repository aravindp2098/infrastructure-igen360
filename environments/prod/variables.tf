variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project" {
  type    = string
  default = "igen-qmetry"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "vpc_cidr" {
  type    = string
  default = "10.30.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.30.11.0/24", "10.30.12.0/24", "10.30.13.0/24"]
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway. Keep false in prod for per-AZ resilience."
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "Extra admin CIDRs allowed to reach the database tier (never 0.0.0.0/0)."
  type        = list(string)
  default     = []
}

# --- Aurora ---
variable "aurora_instance_class" {
  type    = string
  default = "db.r6g.xlarge"
}

variable "aurora_instance_count" {
  type    = number
  default = 2
}

variable "aurora_engine_version" {
  type    = string
  default = "16.4"
}

variable "database_name" {
  type    = string
  default = "qmetry"
}

variable "aurora_master_username" {
  type    = string
  default = "qmetry_admin"
}

variable "backup_retention_period" {
  type    = number
  default = 30
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "skip_final_snapshot" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

# --- ECR ---
variable "ecr_repository_names" {
  description = "ECR repository short names to create."
  type        = list(string)
  default     = ["app"]
}

variable "ecr_image_tag_mutability" {
  description = "Image tag mutability for ECR repositories."
  type        = string
  default     = "IMMUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Enable ECR image scanning on push."
  type        = bool
  default     = true
}

variable "ecr_force_delete" {
  description = "Allow Terraform destroy to delete ECR repositories containing images."
  type        = bool
  default     = false
}

variable "ecr_max_image_count" {
  description = "Maximum images retained per ECR repository."
  type        = number
  default     = 100
}

# --- ECS ---
variable "ecs_image_tag" {
  description = "Image tag deployed by the ECS service."
  type        = string
  default     = "latest"
}

variable "ecs_container_port" {
  description = "Container port exposed by the application."
  type        = number
  default     = 8080
}

variable "ecs_health_check_path" {
  description = "ALB target group health check path."
  type        = string
  default     = "/"
}

variable "ecs_desired_count" {
  description = "Desired ECS task count."
  type        = number
  default     = 2
}

variable "ecs_cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 1024
}

variable "ecs_memory" {
  description = "Fargate task memory in MiB."
  type        = number
  default     = 2048
}

variable "ecs_allowed_cidr_blocks" {
  description = "Extra CIDRs allowed to reach the ALB. Empty by default — CloudFront fronts the ALB. Never 0.0.0.0/0."
  type        = list(string)
  default     = []
}

variable "ecs_environment_variables" {
  description = "Plain text environment variables for the ECS application container."
  type        = map(string)
  default     = {}
}

variable "ecs_log_retention_in_days" {
  description = "CloudWatch log retention for ECS task logs."
  type        = number
  default     = 90
}

variable "ecs_enable_execute_command" {
  description = "Enable ECS Exec for the service. Keep false in prod."
  type        = bool
  default     = false
}

# --- Frontend / CDN / WAF ---
variable "frontend_price_class" {
  description = "CloudFront price class for the frontend CDN."
  type        = string
  default     = "PriceClass_200"
}

variable "frontend_enable_versioning" {
  description = "Enable S3 versioning on the frontend bucket."
  type        = bool
  default     = true
}

variable "frontend_enable_spa_routing" {
  description = "Return index.html for 403/404 on CloudFront (SPA client-side routing)."
  type        = bool
  default     = true
}

variable "frontend_aliases" {
  description = "CloudFront alternate domain names. Overrides frontend_domain_name when non-empty."
  type        = list(string)
  default     = []
}

variable "frontend_domain_name" {
  description = "Optional custom domain for CloudFront (requires frontend_acm_certificate_arn in us-east-1)."
  type        = string
  default     = null
}

variable "frontend_acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1 for custom CloudFront domain."
  type        = string
  default     = null
}

variable "waf_rate_limit" {
  description = "WAF per-IP request limit over a 5-minute window."
  type        = number
  default     = 2000
}
