output "secret_arn" {
  description = "Secrets Manager secret ARN."
  value       = aws_secretsmanager_secret.this.arn
  sensitive   = true
}

output "secret_id" {
  description = "Secrets Manager secret ID."
  value       = aws_secretsmanager_secret.this.id
}

output "password" {
  description = "Master password stored in the secret (provided or generated)."
  value       = local.effective_password
  sensitive   = true
}
