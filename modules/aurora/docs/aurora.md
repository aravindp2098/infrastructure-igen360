# aurora module

Native Aurora PostgreSQL cluster (`aws_rds_cluster` + `aws_rds_cluster_instance`)
hardened for production.

## Defaults

| Setting | Value |
|---------|-------|
| Engine | Aurora PostgreSQL (`engine_version` default 16.4) |
| Instances | 2 (Multi-AZ) |
| Storage encryption | On (`storage_encrypted = true`) |
| Deletion protection | On |
| Backup retention | 30 days |
| Final snapshot | Required (`skip_final_snapshot = false`) |
| IAM database auth | Enabled |
| Enhanced monitoring | 60s interval |
| Performance Insights | Enabled |
| Public accessibility | Off |

## Inputs (key)

- `db_subnet_group_name` — private subnet group from the networking module.
- `vpc_security_group_ids` — the Aurora SG from the security module.
- `master_password` — sourced from the secrets-manager module (never hardcoded).
- `instance_count` — keep >= 2 in prod for failover.

## Outputs

`cluster_endpoint`, `reader_endpoint`, `cluster_identifier`, `database_name`, `port`.
