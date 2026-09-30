# waf module

WAFv2 web ACL for CloudFront. Created in `us-east-1` with `scope = CLOUDFRONT`
(required by AWS). The caller passes a provider aliased to `us-east-1`:

```hcl
module "waf" {
  source = "../../modules/waf"
  providers = {
    aws.us_east_1 = aws.us_east_1
  }
  project     = var.project
  environment = var.environment
  rate_limit  = 2000
}
```

## Rules

1. **rate-limit** (priority 1) — blocks a source IP exceeding `rate_limit`
   requests in a 5-minute window.
2. **AWSManagedRulesCommonRuleSet** (priority 10)
3. **AWSManagedRulesKnownBadInputsRuleSet** (priority 20)
4. **AWSManagedRulesSQLiRuleSet** (priority 30)

Default action is `allow`; managed groups use their own block actions.
Attach the output `web_acl_arn` to the CloudFront distribution via `web_acl_id`.

## Outputs

`web_acl_id`, `web_acl_arn`, `web_acl_name`.
