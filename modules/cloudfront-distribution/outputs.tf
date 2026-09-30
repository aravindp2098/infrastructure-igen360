output "distribution_id" {
  description = "CloudFront distribution ID."
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN."
  value       = aws_cloudfront_distribution.this.arn
}

output "domain_name" {
  description = "CloudFront distribution domain name (e.g. d1234abcd.cloudfront.net)."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "hosted_zone_id" {
  description = "Route53 hosted zone ID for CloudFront alias records."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "frontend_url" {
  description = "HTTPS URL for the frontend (first alias or CloudFront domain)."
  value       = length(var.aliases) > 0 ? "https://${var.aliases[0]}" : "https://${aws_cloudfront_distribution.this.domain_name}"
}

output "vpc_origin_id" {
  description = "VPC origin ID for the API ALB (null when API origin disabled)."
  value       = length(aws_cloudfront_vpc_origin.api) > 0 ? aws_cloudfront_vpc_origin.api[0].id : null
}
