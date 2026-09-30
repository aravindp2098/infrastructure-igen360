# CI/CD access — GitHub OIDC + least-privilege IAM

This repo uses **GitHub OIDC** to assume AWS roles from Actions. There are **no
static `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` secrets** anywhere.

Two roles are referenced by the workflows:

| Secret name | Used by | Purpose |
|-------------|---------|---------|
| `OIDC_ROLE_INFRA` | `terraform.yml` | Plan/apply Terraform for prod |
| `OIDC_ROLE_DEPLOY` | `build-and-push.yml` | Build/push image + roll ECS service |

Repository variables used by `build-and-push.yml`: `ECR_REPOSITORY`, `ECS_CLUSTER`,
`ECS_SERVICE`.

## 1. OIDC identity provider (one-time per account)

Create the GitHub OIDC provider if it does not exist:

- Provider URL: `https://token.actions.githubusercontent.com`
- Audience: `sts.amazonaws.com`

## 2. Trust policy (both roles)

Restrict the trust to this repository and, for apply, the `prod` environment.
Replace `<ACCOUNT_ID>` and the repo owner/name.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:aravindp2098/infrastructure-igen360:*"
        }
      }
    }
  ]
}
```

Tighten `sub` to `repo:aravindp2098/infrastructure-igen360:environment:prod` for the
deploy role so only the protected `prod` environment can assume it.

## 3. Deploy role permissions (`OIDC_ROLE_DEPLOY`)

Least-privilege: push images to the app repo and force a new ECS deployment only.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EcrAuth",
      "Effect": "Allow",
      "Action": "ecr:GetAuthorizationToken",
      "Resource": "*"
    },
    {
      "Sid": "EcrPush",
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ],
      "Resource": "arn:aws:ecr:ap-south-1:<ACCOUNT_ID>:repository/igen-qmetry-prod-app"
    },
    {
      "Sid": "EcsDeploy",
      "Effect": "Allow",
      "Action": [
        "ecs:UpdateService",
        "ecs:DescribeServices"
      ],
      "Resource": "arn:aws:ecs:ap-south-1:<ACCOUNT_ID>:service/igen-qmetry-prod-cluster/igen-qmetry-prod-app"
    }
  ]
}
```

## 4. Terraform role permissions (`OIDC_ROLE_INFRA`)

The plan/apply role needs broader access because it manages VPC, RDS, ECS, ECR,
S3, CloudFront, WAF, IAM, Secrets Manager, and CloudWatch. Scope it as tightly as
your workflow allows. At minimum:

- **State backend:** `s3:GetObject`, `s3:PutObject`, `s3:ListBucket`,
  `s3:DeleteObject` on `arn:aws:s3:::infrastructure-igen360-tfstate-<ACCOUNT_ID>`
  and `/*` (S3 native locking needs object read/write; no DynamoDB required).
- **Resource management:** `ec2:*`, `rds:*`, `ecs:*`, `ecr:*`,
  `elasticloadbalancing:*`, `cloudfront:*`, `wafv2:*`, `s3:*`,
  `secretsmanager:*`, `logs:*`, `iam:*` scoped to the `igen-qmetry-prod-*`
  and `infrastructure-igen360-*` name prefixes wherever the service supports
  resource-level permissions.

Prefer AWS-managed job roles or permission boundaries to cap the blast radius of
the Terraform role. Never attach `AdministratorAccess`.
