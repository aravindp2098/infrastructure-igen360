output "repository_names" {
  description = "ECR repository names by short name."
  value       = { for key, repo in aws_ecr_repository.this : key => repo.name }
}

output "repository_urls" {
  description = "ECR repository URLs by short name."
  value       = { for key, repo in aws_ecr_repository.this : key => repo.repository_url }
}

output "repository_arns" {
  description = "ECR repository ARNs by short name."
  value       = { for key, repo in aws_ecr_repository.this : key => repo.arn }
}
