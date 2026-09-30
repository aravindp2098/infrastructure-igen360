output "web_acl_id" {
  description = "WAFv2 web ACL ID."
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_arn" {
  description = "WAFv2 web ACL ARN (attach to CloudFront)."
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_name" {
  description = "WAFv2 web ACL name."
  value       = aws_wafv2_web_acl.this.name
}
