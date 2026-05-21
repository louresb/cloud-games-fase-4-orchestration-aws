$ErrorActionPreference = "Stop"

$pidFile = Join-Path $PSScriptRoot ".local-port-forwards.pids"
$logDir = Join-Path $PSScriptRoot ".port-forward-logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

if (Test-Path -LiteralPath $pidFile) {
  Get-Content -LiteralPath $pidFile | ForEach-Object {
    if ($_ -match '^\d+$') {
      Stop-Process -Id ([int]$_) -ErrorAction SilentlyContinue
    }
  }
  Remove-Item -LiteralPath $pidFile -Force
}

$forwards = @(
  @{ Name = "users"; Namespace = "fcg-apps"; Service = "users-service"; Local = 30080; Remote = 80 },
  @{ Name = "catalog"; Namespace = "fcg-apps"; Service = "catalog-service"; Local = 30081; Remote = 80 },
  @{ Name = "payments"; Namespace = "fcg-apps"; Service = "payments-service"; Local = 30082; Remote = 80 },
  @{ Name = "notifications"; Namespace = "fcg-apps"; Service = "notifications-service"; Local = 30083; Remote = 80 },
  @{ Name = "audit"; Namespace = "fcg-apps"; Service = "audit-svc"; Local = 30084; Remote = 80 },
  @{ Name = "grafana"; Namespace = "fcg-infra"; Service = "grafana-service"; Local = 30300; Remote = 3000 },
  @{ Name = "rabbitmq"; Namespace = "fcg-infra"; Service = "rabbitmq-service"; Local = 31672; Remote = 15672 }
)

$pids = @()
foreach ($forward in $forwards) {
  $argumentList = @(
    "-n", $forward.Namespace,
    "port-forward", "svc/$($forward.Service)",
    "$($forward.Local):$($forward.Remote)",
    "--address", "127.0.0.1"
  )

  $outFile = Join-Path $logDir "$($forward.Name).out.log"
  $errFile = Join-Path $logDir "$($forward.Name).err.log"

  $process = Start-Process -FilePath "kubectl" `
    -ArgumentList $argumentList `
    -WindowStyle Hidden `
    -RedirectStandardOutput $outFile `
    -RedirectStandardError $errFile `
    -PassThru

  $pids += $process.Id
}

$pids | Set-Content -LiteralPath $pidFile
Start-Sleep -Seconds 3

Write-Host "Port-forwards ativos:"
Write-Host "Users:         http://localhost:30080/health/ready"
Write-Host "Catalog:       http://localhost:30081/health/ready"
Write-Host "Payments:      http://localhost:30082/health/ready"
Write-Host "Notifications: http://localhost:30083/health/ready"
Write-Host "Audit:         http://localhost:30084/health/ready"
Write-Host "Grafana:       http://localhost:30300"
Write-Host "RabbitMQ:      http://localhost:31672"
Write-Host ""
Write-Host "Para parar: .\scripts\stop-local-port-forwards.ps1"