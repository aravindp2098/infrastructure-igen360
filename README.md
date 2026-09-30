# infrastructure-igen360 — Production AWS Infrastructure

Production-grade, security-hardened Terraform for the `igen-qmetry` platform.
This repository contains a single `prod` environment that calls self-contained,
hardened modules. It is separate from the dev/staging repo so that production
code, state, and access are fully isolated.

Region: `ap-south-1`. Project: `igen-qmetry`.

## Structure

```
infrastructure-igen360/
├── modules/
│   ├── networking/               # VPC, private/public subnets, NAT, flow logs, VPC endpoints
│   ├── security/                 # Aurora security group (no public ingress)
│   ├── secrets-manager/          # DB master credentials
│   ├── aurora/                   # Aurora PostgreSQL (encrypted, Multi-AZ, protected)
│   ├── ecr/                      # Container registry (IMMUTABLE, scan on push)
│   ├── ecs/                      # Fargate + internal ALB (CloudFront-only ingress)
│   ├── s3-static-site/           # Frontend bucket (OAC, public access blocked)
│   ├── cloudfront-distribution/  # CDN + /api/* VPC origin + WAF association
│   └── waf/                      # WAFv2 web ACL (managed rules + rate limiting)
├── environments/
│   └── prod/                     # Prod environment wiring all modules
├── scripts/
│   └── bootstrap-backend.ps1     # One-time S3 state bucket creation
├── .github/workflows/            # OIDC CI: terraform, build-and-push, scan
├── docs/                         # CI/IAM and excluded-module notes
└── PLAN.md                       # Implementation plan
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.10
- AWS CLI configured (`aws sts get-caller-identity`)
- A dedicated S3 state bucket (created by the bootstrap script below)

## Quick start

### 1. Bootstrap remote state (once per account)

```powershell
cd scripts
.\bootstrap-backend.ps1 -Region ap-south-1
```

Update `environments/prod/backend.tf`, replacing `<ACCOUNT_ID>` in the bucket name
with your AWS account ID (or pass `-backend-config="bucket=..."` at init time).

### 2. Init / plan (no apply without approval)

```powershell
cd environments/prod
terraform init
terraform plan
```

Applies run through CI behind a protected `prod` GitHub Environment (see below),
not from a workstation.

## Security posture

- **Networking:** database tier is private-only; VPC flow logs enabled; per-AZ NAT;
  interface + gateway VPC endpoints for ECR, Logs, Secrets Manager, S3.
- **Compute:** internal ALB; ALB ingress restricted to the CloudFront
  origin-facing managed prefix list (never `0.0.0.0/0`, enforced by variable
  validation); Fargate tasks in private subnets with no public IP; ECS Exec off.
- **Edge:** CloudFront + WAFv2 (AWS managed rule sets + per-IP rate limiting);
  TLS 1.2+; S3 reachable only through Origin Access Control.
- **Data:** Aurora encrypted at rest, deletion protection on, 30-day backups,
  final snapshot required, IAM database auth enabled. Secrets in Secrets Manager
  with a 30-day recovery window.
- **CI/CD:** GitHub OIDC `AssumeRole` — no static AWS keys. `plan` on PR; `apply`
  gated behind a protected `prod` environment with required reviewers. `tflint`,
  `checkov`, and `tfsec` run on every PR. See `docs/ci-oidc-iam.md`.
- **State:** dedicated versioned + encrypted S3 bucket, public access fully
  blocked, S3 native locking (`use_lockfile = true`).

## CI/CD

| Workflow | Trigger | Action |
|----------|---------|--------|
| `terraform.yml` | PR (plan), manual dispatch (apply) | Terraform plan/apply for prod |
| `build-and-push.yml` | manual dispatch | Build image, push to ECR, roll ECS |
| `scan.yml` | PR, manual dispatch | tflint + checkov + tfsec |

Required GitHub secrets: `OIDC_ROLE_INFRA`, `OIDC_ROLE_DEPLOY`.
Required GitHub variables: `ECR_REPOSITORY`, `ECS_CLUSTER`, `ECS_SERVICE`.

## Notes

- This repo authors infrastructure as code only. No resources are provisioned by
  cloning it — run the bootstrap script and CI apply to deploy.
- Dev-only modules (public RDS, public ClickHouse, public runner) are intentionally
  excluded. See `docs/excluded-modules.md`.
