output "vpc_id" {
  value = module.networking.vpc_id
}

output "aurora_cluster_endpoint" {
  value = module.aurora.cluster_endpoint
}

output "aurora_reader_endpoint" {
  value = module.aurora.reader_endpoint
}

output "aurora_master_secret_arn" {
  value     = module.aurora_master_secret.secret_arn
  sensitive = true
}

output "database_name" {
  value = module.aurora.database_name
}

output "ecr_repository_urls" {
  description = "ECR repository URLs by short name."
  value       = module.ecr.repository_urls
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = module.ecs.service_name
}

output "ecs_alb_dns_name" {
  description = "Internal ALB DNS name for the ECS application."
  value       = module.ecs.alb_dns_name
}

output "frontend_bucket_name" {
  description = "S3 bucket name for frontend static assets."
  value       = module.frontend_s3.bucket_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID."
  value       = module.frontend_cdn.distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name."
  value       = module.frontend_cdn.domain_name
}

output "frontend_url" {
  description = "HTTPS URL for the frontend application."
  value       = module.frontend_cdn.frontend_url
}

output "waf_web_acl_arn" {
  description = "WAFv2 web ACL ARN attached to CloudFront."
  value       = module.waf.web_acl_arn
}
