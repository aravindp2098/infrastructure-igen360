terraform {
  backend "s3" {
    # Dedicated prod state bucket. Create it once with scripts/bootstrap-backend.ps1,
    # then replace <ACCOUNT_ID> below with your AWS account ID (or pass -backend-config).
    bucket       = "infrastructure-igen360-tfstate-<ACCOUNT_ID>"
    key          = "prod/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
