# Prod: private VPC + Aurora (encrypted, protected) + ECS Fargate (internal ALB) +
# CloudFront (VPC origin for /api/*) fronted by WAFv2. No public DB, no public runner.

locals {
  frontend_aliases = length(var.frontend_aliases) > 0 ? var.frontend_aliases : (
    var.frontend_domain_name != null ? [var.frontend_domain_name] : []
  )
}

module "networking" {
  source = "../../modules/networking"

  project              = var.project
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
  enable_vpc_endpoints = true
  enable_flow_logs     = true
  tags                 = var.tags
}

module "security" {
  source = "../../modules/security"

  project             = var.project
  environment         = var.environment
  vpc_id              = module.networking.vpc_id
  allowed_cidr_blocks = concat([var.vpc_cidr], var.allowed_cidr_blocks)
  allowed_security_group_ids = [
    module.ecs.service_security_group_id
  ]
  tags = var.tags
}

module "aurora_master_secret" {
  source = "../../modules/secrets-manager"

  project     = var.project
  environment = var.environment
  name        = "aurora-master"
  username    = var.aurora_master_username
  engine      = "aurora-postgresql"
  dbname      = var.database_name
  tags        = var.tags
}

module "aurora" {
  source = "../../modules/aurora"

  project              = var.project
  environment          = var.environment
  db_subnet_group_name = module.networking.db_subnet_group_name
  vpc_security_group_ids = [
    module.security.aurora_security_group_id
  ]
  master_password = module.aurora_master_secret.password

  engine_version          = var.aurora_engine_version
  database_name           = var.database_name
  master_username         = var.aurora_master_username
  instance_class          = var.aurora_instance_class
  instance_count          = var.aurora_instance_count
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  storage_encrypted       = true
  apply_immediately       = false

  tags = var.tags
}

module "ecr" {
  source = "../../modules/ecr"

  project              = var.project
  environment          = var.environment
  repository_names     = var.ecr_repository_names
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push
  force_delete         = var.ecr_force_delete
  max_image_count      = var.ecr_max_image_count
  tags                 = var.tags
}

module "ecs" {
  source = "../../modules/ecs"

  project                     = var.project
  environment                 = var.environment
  vpc_id                      = module.networking.vpc_id
  alb_subnet_ids              = module.networking.private_subnet_ids
  service_subnet_ids          = module.networking.private_subnet_ids
  container_image             = "${module.ecr.repository_urls["app"]}:${var.ecs_image_tag}"
  container_port              = var.ecs_container_port
  health_check_path           = var.ecs_health_check_path
  desired_count               = var.ecs_desired_count
  cpu                         = var.ecs_cpu
  memory                      = var.ecs_memory
  assign_public_ip            = false
  allowed_cidr_blocks         = var.ecs_allowed_cidr_blocks
  allow_cloudfront_vpc_origin = true
  environment_variables = merge(var.ecs_environment_variables, {
    DATABASE_HOST = module.aurora.cluster_endpoint
    DATABASE_NAME = module.aurora.database_name
  })
  secrets = {
    DATABASE_SECRET_ARN = module.aurora_master_secret.secret_arn
  }
  log_retention_in_days  = var.ecs_log_retention_in_days
  enable_execute_command = var.ecs_enable_execute_command
  tags                   = var.tags
}

module "waf" {
  source = "../../modules/waf"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  project     = var.project
  environment = var.environment
  rate_limit  = var.waf_rate_limit
  tags        = var.tags
}

module "frontend_s3" {
  source = "../../modules/s3-static-site"

  project           = var.project
  environment       = var.environment
  enable_versioning = var.frontend_enable_versioning
  tags              = var.tags
}

module "frontend_cdn" {
  source = "../../modules/cloudfront-distribution"

  project                        = var.project
  environment                    = var.environment
  s3_bucket_name                 = module.frontend_s3.bucket_name
  s3_bucket_arn                  = module.frontend_s3.bucket_arn
  s3_bucket_regional_domain_name = module.frontend_s3.bucket_regional_domain_name
  web_acl_id                     = module.waf.web_acl_arn
  enable_api_origin              = true
  alb_arn                        = module.ecs.alb_arn
  alb_dns_name                   = module.ecs.alb_dns_name
  aliases                        = local.frontend_aliases
  acm_certificate_arn            = var.frontend_acm_certificate_arn
  api_path_pattern               = "/api/*"
  enable_spa_routing             = var.frontend_enable_spa_routing
  price_class                    = var.frontend_price_class
  tags                           = var.tags
}
