output "aurora_security_group_id" {
  description = "Security group ID for Aurora cluster."
  value       = aws_security_group.aurora.id
}
