# Prod — hardened values. Private DB, Multi-AZ Aurora, internal ALB + CloudFront/WAF.

environment             = "prod"
aws_region              = "ap-south-1"
vpc_cidr                = "10.30.0.0/16"
single_nat_gateway      = false
aurora_instance_class   = "db.r6g.xlarge"
aurora_instance_count   = 2
aurora_engine_version   = "16.4"
backup_retention_period = 30
deletion_protection     = true
skip_final_snapshot     = false

ecr_image_tag_mutability = "IMMUTABLE"
ecr_scan_on_push         = true
ecr_force_delete         = false

ecs_image_tag              = "latest"
ecs_container_port         = 8080
ecs_health_check_path      = "/"
ecs_desired_count          = 2
ecs_cpu                    = 1024
ecs_memory                 = 2048
ecs_allowed_cidr_blocks    = []
ecs_enable_execute_command = false
ecs_log_retention_in_days  = 90

frontend_price_class        = "PriceClass_200"
frontend_enable_versioning  = true
frontend_enable_spa_routing = true
waf_rate_limit              = 2000

# Optional CDN custom domains (empty = *.cloudfront.net)
# frontend_aliases             = ["qmetryigen.ai", "*.qmetryigen.ai"]
# frontend_acm_certificate_arn = "arn:aws:acm:us-east-1:ACCOUNT:certificate/..."

tags = {
  CostCenter = "engineering"
  Owner      = "platform-team"
  Compliance = "required"
}
