<#
.SYNOPSIS
    Remove todos os recursos Kubernetes da infraestrutura
#>

function Log-Info ($Message) { Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor Cyan }
function Log-Warn ($Message) { Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor Yellow }
function Log-Success ($Message) { Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor Green }

Log-Warn "Removendo infraestrutura do Kubernetes..."
Write-Host ""

$confirm = Read-Host "Confirmar remocao? (digite 'SIM')"
if ($confirm -ne "SIM") {
    Log-Info "Operacao cancelada"
    exit 0
}

Log-Info "Removendo namespace fcg-infra..."
kubectl delete namespace fcg-infra

if ($LASTEXITCODE -eq 0) {
    Log-Success "Namespace removido"
} else {
    Log-Warn "Namespace nao encontrado ou ja removido"
}