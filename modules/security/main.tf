variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  description = "VPC to attach security groups to."
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to PostgreSQL. Prod should use the VPC CIDR and/or specific admin ranges only — never 0.0.0.0/0."
  type        = list(string)
  default     = []

  validation {
    condition     = !contains(var.allowed_cidr_blocks, "0.0.0.0/0")
    error_message = "The database security group must not allow 0.0.0.0/0. Restrict to the VPC CIDR or specific admin ranges."
  }
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to Aurora (e.g. the ECS service SG)."
  type        = list(string)
  default     = []
}

variable "db_port" {
  description = "Database port for ingress rules."
  type        = number
  default     = 5432
}

variable "tags" {
  type    = map(string)
  default = {}
}

locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "security"
  })
}

resource "aws_security_group" "aurora" {
  name        = "${local.name_prefix}-aurora-sg"
  description = "Controls ingress to Aurora cluster"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "aurora_from_cidr" {
  count = length(var.allowed_cidr_blocks)

  security_group_id = aws_security_group.aurora.id
  cidr_ipv4         = var.allowed_cidr_blocks[count.index]
  from_port         = var.db_port
  to_port           = var.db_port
  ip_protocol       = "tcp"
  description       = "PostgreSQL from allowed CIDR"
}

resource "aws_vpc_security_group_ingress_rule" "aurora_from_sg" {
  count = length(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.aurora.id
  referenced_security_group_id = var.allowed_security_group_ids[count.index]
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
  description                  = "PostgreSQL from allowed security group"
}
