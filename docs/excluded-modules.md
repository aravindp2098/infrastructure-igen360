# Excluded modules

The source repo (`IGEN-Infra-DevOps`) shipped several modules that are intentionally
**not** carried into this production repo because they were dev conveniences that
weaken a production security posture.

| Module | Why excluded | Prod alternative |
|--------|--------------|------------------|
| `rds-postgres` | Dev used a single, publicly accessible RDS instance (`publicly_accessible = true`, SG open to `0.0.0.0/0`). | `aurora` module — encrypted, Multi-AZ, private subnets, deletion protection. |
| `ec2-clickhouse` | Dev exposed ClickHouse on a public EC2 instance to `0.0.0.0/0`. | Not part of the prod stack. If analytics are needed, add a private-subnet module with SG-restricted ingress. |
| `ec2-redis` | EC2-hosted Redis without managed failover; not part of the prod stack today. | Add `elasticache` (private, encrypted, auth token) when caching is required. |
| `elasticache-serverless` | Not wired into prod today. | Add later, private-only, with encryption in transit + at rest. |
| `github-actions-runner` | Dev ran a public EC2 self-hosted runner with SSH ingress. | GitHub-hosted runners + OIDC `AssumeRole` (see `ci-oidc-iam.md`). No standing compute, no inbound SSH. |

If any of these are needed in prod later, add a hardened module (private subnets,
no public IP, SG-restricted ingress, encryption on) rather than porting the dev
version.
