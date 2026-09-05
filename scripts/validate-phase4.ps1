$ErrorActionPreference = "Stop"

$orchestrationRoot = Split-Path -Parent $PSScriptRoot
$workspaceRoot = Split-Path -Parent $orchestrationRoot

$repos = @(
  @{ Name = "users"; Sln = Join-Path $workspaceRoot "cloud-games-fase-4-users\cloud-games-fase-4-users.sln" },
  @{ Name = "catalog"; Sln = Join-Path $workspaceRoot "cloud-games-fase-4-catalog\cloud-games-fase-4-catalog.sln" },
  @{ Name = "payments"; Sln = Join-Path $workspaceRoot "cloud-games-fase-4-payments\cloud-games-fase-4-payments.sln" },
  @{ Name = "notifications"; Sln = Join-Path $workspaceRoot "cloud-games-fase-4-notifications\cloud-games-fase-4-notifications.sln" },
  @{ Name = "audit"; Sln = Join-Path $workspaceRoot "cloud-games-fase-4-audit\Fiap.CloudGames.Audit.sln" }
)

foreach ($repo in $repos) {
  Write-Host "==> Building $($repo.Name)" -ForegroundColor Cyan
  dotnet build $repo.Sln -c Release --nologo
  Write-Host "==> Testing $($repo.Name)" -ForegroundColor Cyan
  dotnet test $repo.Sln -c Release --nologo --no-build
}

Write-Host "==> Tooling" -ForegroundColor Cyan
if (Get-Command docker -ErrorAction SilentlyContinue) { docker version --format "Docker client={{.Client.Version}} server={{.Server.Version}}" } else { Write-Warning "docker not found" }
if (Get-Command kubectl -ErrorAction SilentlyContinue) { kubectl version --client --output=yaml } else { Write-Warning "kubectl not found" }
if (Get-Command terraform -ErrorAction SilentlyContinue) {
  Push-Location (Join-Path $orchestrationRoot "terraform")
  terraform fmt -check -recursive
  terraform validate
  Pop-Location
} else {
  Write-Warning "terraform not found in PATH; run terraform init/validate in the demo environment."
}
