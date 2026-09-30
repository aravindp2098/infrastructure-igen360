locals {
  name_prefix       = "${var.project}-${var.environment}"
  s3_origin_id      = "S3-${var.s3_bucket_regional_domain_name}"
  api_origin_id     = var.enable_api_origin ? "ALB-api" : "ALB-disabled"
  use_custom_domain = length(var.aliases) > 0 && var.acm_certificate_arn != null
  enable_api_origin = var.enable_api_origin
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "cloudfront-distribution"
  })
}

resource "aws_cloudfront_origin_access_control" "s3" {
  name                              = "${local.name_prefix}-frontend-oac"
  description                       = "OAC for ${var.s3_bucket_regional_domain_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_vpc_origin" "api" {
  count = local.enable_api_origin ? 1 : 0

  vpc_origin_endpoint_config {
    name                   = "${local.name_prefix}-api-vpc-origin"
    arn                    = var.alb_arn
    http_port              = var.api_origin_http_port
    https_port             = var.api_origin_https_port
    origin_protocol_policy = "http-only"

    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }

  timeouts {
    create = "30m"
  }
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = var.enable_ipv6
  comment             = "${local.name_prefix} frontend CDN"
  default_root_object = var.default_root_object
  price_class         = var.price_class
  http_version        = "http2and3"
  aliases             = local.use_custom_domain ? var.aliases : []
  web_acl_id          = var.web_acl_id

  origin {
    domain_name              = var.s3_bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  dynamic "origin" {
    for_each = local.enable_api_origin ? [1] : []

    content {
      domain_name = var.alb_dns_name
      origin_id   = local.api_origin_id

      vpc_origin_config {
        vpc_origin_id = aws_cloudfront_vpc_origin.api[0].id
      }
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = var.default_ttl
    max_ttl     = var.max_ttl
  }

  dynamic "ordered_cache_behavior" {
    for_each = local.enable_api_origin ? [1] : []

    content {
      path_pattern           = var.api_path_pattern
      allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods         = ["GET", "HEAD"]
      target_origin_id       = local.api_origin_id
      viewer_protocol_policy = "redirect-to-https"
      compress               = true

      forwarded_values {
        query_string = true
        headers      = ["Host", "Authorization"]

        cookies {
          forward = "all"
        }
      }

      min_ttl     = 0
      default_ttl = 0
      max_ttl     = 0
    }
  }

  dynamic "custom_error_response" {
    for_each = var.enable_spa_routing ? [403, 404] : []

    content {
      error_code            = custom_error_response.value
      response_code         = 200
      response_page_path    = "/${var.default_root_object}"
      error_caching_min_ttl = 10
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = !local.use_custom_domain
    acm_certificate_arn            = local.use_custom_domain ? var.acm_certificate_arn : null
    ssl_support_method             = local.use_custom_domain ? "sni-only" : null
    minimum_protocol_version       = local.use_custom_domain ? "TLSv1.2_2021" : null
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cdn"
  })
}

resource "aws_s3_bucket_policy" "this" {
  bucket = var.s3_bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${var.s3_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      }
    ]
  })
}
