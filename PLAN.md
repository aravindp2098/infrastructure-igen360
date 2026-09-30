# Implementation Plan — Production Secure Repo (`infrastructure-igen360`)

## Goal

Author (code only — **no `terraform apply`, no live infrastructure**) a separate,
production-grade Terraform repository for the `igen-qmetry` platform. This repo
contains a single hardened `prod` environment that calls self-contained, hardened
copies of the service modules. It includes a dedicated S3 state backend (as code +
bootstrap script), strict least-privilege OIDC CI (no static AWS keys), and this
plan document.

- **Target repo:** https://github.com/aravindp2098/infrastructure-igen360.git
- **Clone location:** `D:\infrastructure-igen360` (outside the source workspace)
- **Scope:** prod-only hardened environment calling shared modules
- **Region:** `ap-south-1`
- **Project:** `igen-qmetry`

## Source context

Ported and hardened from `IGEN-Infra-DevOps`. That repo intentionally kept dev
public (public RDS, public ClickHouse, public GitHub runner, static AWS keys in CI).
This repo carries **only** the modules prod uses and hardens them further.

### Modules included (self-contained, hardened)

| Module | Purpose | Hardening |
|--------|---------|-----------|
| `networking` | VPC, public/private subnets, NAT, flow logs | Private-subnet DB only, flow logs on by default, CIDR validation |
| `security` | Aurora/DB security groups | Ingress by explicit CIDR/SG only, no public default |
| `secrets-manager` | DB master credentials | 30-day recovery window in prod, generated password |
| `aurora` | Aurora PostgreSQL cluster (native) | Encrypted, deletion protection, Multi-AZ, 30-day backups |
| `ecr` | Container registry | `IMMUTABLE` tags, scan on push, `force_delete=false` |
| `ecs` | Fargate + internal ALB | `assign_public_ip=false`, ALB ingress from CloudFront only, least-priv task IAM |
| `s3-static-site` | Frontend bucket | Public access blocked, encrypted, versioned, OAC-only access |
| `cloudfront-distribution` | Frontend CDN + `/api/*` VPC origin | WAF web ACL attached, TLS 1.2+, redirect-to-https |
| `waf` | WAFv2 web ACL (new) | AWS managed rule sets + rate limiting |

### Modules intentionally excluded (dev-only / not prod-safe)

- `rds-postgres` — dev used a public single-instance RDS; prod uses Aurora.
- `ec2-clickhouse` — dev exposed ClickHouse to `0.0.0.0/0`.
- `ec2-redis` / `elasticache-serverless` — not part of the prod stack today; add a
  hardened cache module later if needed.
- `github-actions-runner` — dev ran a public EC2 runner; prod uses GitHub-hosted
  runners with OIDC.

See `docs/excluded-modules.md`.

## Security hardening summary

- **Networking:** DB tier private-only, VPC flow logs enabled, per-AZ NAT option.
- **Compute:** internal ALB; ALB SG ingress restricted to the CloudFront
  origin-facing managed prefix list (not `0.0.0.0/0`); ECS tasks in private subnets
  with no public IP; ECS Exec disabled.
- **Edge:** CloudFront + WAFv2 (AWS managed rules + rate limiting), TLS 1.2+,
  S3 reachable only via Origin Access Control.
- **Data:** Aurora encrypted at rest, deletion protection on, 30-day backups,
  final snapshot required. Secrets in Secrets Manager with a 30-day recovery window.
- **CI/CD:** GitHub OIDC `AssumeRole` (no static `AWS_ACCESS_KEY_ID`/secret);
  `plan` on PR, `apply` gated behind a protected `prod` GitHub Environment with
  required reviewers; `tflint` + `checkov`/`tfsec` scanning. Least-privilege deploy
  role policy documented under `docs/`.
- **State:** dedicated versioned + encrypted S3 bucket, public access fully blocked,
  S3 native locking (`use_lockfile = true`).

## Task breakdown

1. Clone repo + scaffold (`modules/`, `environments/prod/`, `scripts/`,
   `.github/workflows/`, `docs/`, `.gitignore`, `.gitattributes`, `PLAN.md`).
2. Port `networking` + `security` (hardened).
3. Port `aurora` (native) + `secrets-manager`; exclude dev-only modules.
4. Port `ecs` + `ecr` with ALB lockdown.
5. Port `s3-static-site` + `cloudfront-distribution`; add `waf`.
6. Author `environments/prod` calling all modules.
7. Add dedicated `backend.tf` + `bootstrap-backend.ps1`.
8. Add OIDC CI: `terraform.yml`, `build-and-push.yml`, scanning workflow, IAM policy doc.
9. README + per-module docs; repo-wide `fmt`/`validate`; commit feature branch,
   push, open PR.

## Verification (no apply)

- `terraform fmt -check -recursive`
- `terraform init -backend=false` (per module / env)
- `terraform validate`

All infrastructure (state bucket, OIDC role) is defined **as code / scripts only**
and is **not** provisioned by this work.
