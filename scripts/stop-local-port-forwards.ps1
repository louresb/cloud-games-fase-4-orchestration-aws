$ErrorActionPreference = "Stop"

$pidFile = Join-Path $PSScriptRoot ".local-port-forwards.pids"

if (-not (Test-Path -LiteralPath $pidFile)) {
  Write-Host "Nenhum port-forward local registrado."
  exit 0
}

Get-Content -LiteralPath $pidFile | ForEach-Object {
  if ($_ -match '^\d+$') {
    Stop-Process -Id ([int]$_) -ErrorAction SilentlyContinue
  }
}

Remove-Item -LiteralPath $pidFile -Force
Write-Host "Port-forwards locais encerrados."