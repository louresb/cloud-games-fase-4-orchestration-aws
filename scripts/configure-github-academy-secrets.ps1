param(
  [string] $Owner = "louresb",
  [string] $AwsRegion = $(if ($env:AWS_REGION) { $env:AWS_REGION } else { "us-east-1" }),
  [string] $EksCluster = $(if ($env:EKS_CLUSTER) { $env:EKS_CLUSTER } else { "cloud-games-dev-eks" }),
  [string] $K8sNamespace = $(if ($env:K8S_NAMESPACE) { $env:K8S_NAMESPACE } else { "fcg-apps" })
)

$ErrorActionPreference = "Stop"

$requiredEnv = @(
  "AWS_ACCESS_KEY_ID",
  "AWS_SECRET_ACCESS_KEY",
  "AWS_SESSION_TOKEN"
)

foreach ($name in $requiredEnv) {
  if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($name))) {
    throw "Environment variable $name is required. Export the AWS Academy values in PowerShell before running this script."
  }
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  throw "GitHub CLI (gh) was not found. Install it or configure the secrets manually in GitHub Actions settings."
}

$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
  throw "GitHub CLI is not authenticated. Run: gh auth login"
}

$repositories = @(
  "cloud-games-fase-4-users",
  "cloud-games-fase-4-catalog",
  "cloud-games-fase-4-payments",
  "cloud-games-fase-4-notifications",
  "cloud-games-fase-4-audit"
)

foreach ($repoName in $repositories) {
  $fullName = "$Owner/$repoName"
  Write-Host "==> Configuring GitHub Actions secrets/variables for $fullName" -ForegroundColor Cyan

  $env:AWS_ACCESS_KEY_ID | gh secret set AWS_ACCESS_KEY_ID --repo $fullName
  $env:AWS_SECRET_ACCESS_KEY | gh secret set AWS_SECRET_ACCESS_KEY --repo $fullName
  $env:AWS_SESSION_TOKEN | gh secret set AWS_SESSION_TOKEN --repo $fullName

  gh variable set AWS_REGION --repo $fullName --body $AwsRegion
  gh variable set EKS_CLUSTER --repo $fullName --body $EksCluster
  gh variable set K8S_NAMESPACE --repo $fullName --body $K8sNamespace
}

Write-Host "GitHub Actions configuration completed. Re-run the failed workflows manually while the AWS Academy lab is active." -ForegroundColor Green
