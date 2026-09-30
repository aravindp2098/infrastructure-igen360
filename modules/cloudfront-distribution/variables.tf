variable "project" {
  description = "Project name used in resource naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name (for bucket policy resource)."
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN for OAC bucket policy."
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket (S3 origin)."
  type        = string
}

variable "web_acl_id" {
  description = "WAFv2 web ACL ARN to associate with the distribution. Null disables WAF."
  type        = string
  default     = null
}

variable "enable_api_origin" {
  description = "Create CloudFront VPC origin + /api/* behavior."
  type        = bool
  default     = false
}

variable "alb_arn" {
  description = "Internal ALB ARN for VPC origin (/api/*). Required when enable_api_origin is true."
  type        = string
  default     = null
}

variable "alb_dns_name" {
  description = "Internal ALB DNS name for VPC origin. Required when enable_api_origin is true."
  type        = string
  default     = null
}

variable "api_path_pattern" {
  description = "Path pattern routed to the VPC origin (ALB)."
  type        = string
  default     = "/api/*"
}

variable "api_origin_http_port" {
  description = "HTTP port on the ALB for VPC origin."
  type        = number
  default     = 80
}

variable "api_origin_https_port" {
  description = "HTTPS port on the ALB for VPC origin (required by AWS API)."
  type        = number
  default     = 443
}

variable "aliases" {
  description = "CloudFront alternate domain names (e.g. qmetryigen.ai, *.qmetryigen.ai)."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1 for custom domains. Required when aliases is non-empty."
  type        = string
  default     = null
}

variable "default_root_object" {
  description = "Default object served at the CloudFront root path."
  type        = string
  default     = "index.html"
}

variable "enable_spa_routing" {
  description = "Return index.html for 403/404 errors (client-side routing)."
  type        = bool
  default     = true
}

variable "enable_ipv6" {
  description = "Enable IPv6 on the CloudFront distribution."
  type        = bool
  default     = true
}

variable "price_class" {
  description = "CloudFront price class."
  type        = string
  default     = "PriceClass_200"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.price_class)
    error_message = "price_class must be PriceClass_100, PriceClass_200, or PriceClass_All."
  }
}

variable "default_ttl" {
  description = "Default TTL in seconds for static asset cache behavior."
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum TTL in seconds for static asset cache behavior."
  type        = number
  default     = 86400
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
