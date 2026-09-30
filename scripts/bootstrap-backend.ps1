# Creates the dedicated S3 bucket for Terraform remote state (S3 native locking via use_lockfile).
#
# Run ONCE per account/region before the first `terraform init`.
# Requires Terraform >= 1.10 for S3 lock files and a configured AWS CLI.
#
# Usage:
#   .\bootstrap-backend.ps1 -Region ap-south-1
#
# After it runs, update environments/prod/backend.tf with the printed bucket name.

param(
    [string]$Region = "ap-south-1",
    [string]$Project = "infrastructure-igen360"
)

$ErrorActionPreference = "Stop"

$AccountId  = (aws sts get-caller-identity --query Account --output text)
$BucketName = "$Project-tfstate-$AccountId"

Write-Host "Account : $AccountId"
Write-Host "Region  : $Region"
Write-Host "Bucket  : $BucketName"

# Create the bucket if it does not already exist.
if (-not (aws s3api head-bucket --bucket $BucketName 2>$null)) {
    if ($Region -eq "us-east-1") {
        $createBucketArgs = @('s3api', 'create-bucket', '--bucket', $BucketName, '--region', $Region)
        & aws @createBucketArgs
    }
    else {
        $createBucketArgs = @('s3api', 'create-bucket', '--bucket', $BucketName, '--region', $Region, '--create-bucket-configuration', "LocationConstraint=$Region")
        & aws @createBucketArgs
    }

    # Versioning — keep state history.
    $versioningArgs = @('s3api', 'put-bucket-versioning', '--bucket', $BucketName, '--versioning-configuration', 'Status=Enabled')
    & aws @versioningArgs

    # Default encryption (AES256).
    $EncryptionFile = Join-Path $env:TEMP "tf-state-encryption.json"
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}},{"BucketKeyEnabled":true}]}' | Set-Content -Path $EncryptionFile -Encoding ascii
    $encryptionArgs = @('s3api', 'put-bucket-encryption', '--bucket', $BucketName, '--server-side-encryption-configuration', "file://$EncryptionFile")
    & aws @encryptionArgs
    Remove-Item $EncryptionFile -ErrorAction SilentlyContinue

    # Block all public access.
    $publicAccessArgs = @('s3api', 'put-public-access-block', '--bucket', $BucketName, '--public-access-block-configuration', 'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true')
    & aws @publicAccessArgs

    Write-Host "Created S3 bucket: $BucketName"
}
else {
    Write-Host "S3 bucket already exists: $BucketName"
}

Write-Host ""
Write-Host "Update environments/prod/backend.tf with:"
Write-Host "  bucket       = `"$BucketName`""
Write-Host "  region       = `"$Region`""
Write-Host "  key          = `"prod/terraform.tfstate`""
Write-Host "  use_lockfile = true"
