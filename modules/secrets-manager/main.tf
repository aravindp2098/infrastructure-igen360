locals {
  name_prefix = "${var.project}-${var.environment}"
  secret_name = "${local.name_prefix}-${var.name}"
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "secrets-manager"
  })
  effective_password = var.password != null && var.password != "" ? var.password : random_password.this.result
}

resource "random_password" "this" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "this" {
  name                    = local.secret_name
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(local.common_tags, {
    Name = local.secret_name
  })
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    username = var.username
    password = local.effective_password
    engine   = var.engine
    dbname   = var.dbname
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}
