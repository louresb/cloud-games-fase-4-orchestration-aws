<#
.SYNOPSIS
    Aplica todos os manifestos Kubernetes da infraestrutura
#>

param (
    [Parameter(Mandatory=$false)]
    [switch]$SkipWait
)

function Log-Info ($Message) { Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor Cyan }
function Log-Warn ($Message) { Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor Yellow }
function Log-Success ($Message) { Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor Green }

function Apply-Manifest ($FilePath, $Description) {
    if (Test-Path $FilePath) {
        Write-Host "Aplicando:  $Description" -ForegroundColor Gray
        kubectl apply -f $FilePath
        if ($LASTEXITCODE -ne 0) {
            Log-Warn "Falha ao aplicar:  $Description"
        }
    } else {
        Log-Warn "Arquivo não encontrado: $FilePath"
    }
}

Log-Info "Iniciando deploy da infraestrutura..."

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Log-Warn "kubectl não encontrado no PATH"
    exit 1
}

kubectl cluster-info --request-timeout=5s > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Log-Warn "Cluster Kubernetes não acessível"
    exit 1
}

Log-Info "--- [1/6] Namespace ---"
Apply-Manifest "k8s/fcg-infra-namespace.yaml" "Namespace"

Log-Info "--- [2/6] Secrets ---"
Apply-Manifest "k8s/sqlserver-secret.yaml" "SQL Server Secret"
Apply-Manifest "k8s/rabbitmq-secret.yaml" "RabbitMQ Secret"
Apply-Manifest "k8s/grafana-secret.yaml" "Grafana Secret"

Log-Info "--- [3/6] PVCs ---"
Apply-Manifest "k8s/sqlserver-pvc.yaml" "SQL Server PVC"
Apply-Manifest "k8s/rabbitmq-pvc.yaml" "RabbitMQ PVC"
Apply-Manifest "k8s/loki-pvc.yaml" "Loki PVC"

Log-Info "--- [4/6] ConfigMaps ---"
Apply-Manifest "k8s/grafana-configmap.yaml" "Grafana ConfigMap"

Log-Info "--- [5/6] Services ---"
Apply-Manifest "k8s/sqlserver-service.yaml" "SQL Server Service"
Apply-Manifest "k8s/rabbitmq-service.yaml" "RabbitMQ Service"
Apply-Manifest "k8s/loki-service.yaml" "Loki Service"
Apply-Manifest "k8s/grafana-service.yaml" "Grafana Service"

Log-Info "--- [6/6] Deployments ---"
Apply-Manifest "k8s/sqlserver-deployment.yaml" "SQL Server Deployment"
Apply-Manifest "k8s/rabbitmq-deployment.yaml" "RabbitMQ Deployment"
Apply-Manifest "k8s/loki-deployment.yaml" "Loki Deployment"
Apply-Manifest "k8s/grafana-deployment.yaml" "Grafana Deployment"

Log-Success "Manifestos aplicados"

if (-not $SkipWait) {
    Log-Info "Aguardando pods ficarem prontos..."
    kubectl wait --for=condition=ready pod --all -n fcg-infra --timeout=300s
    
    if ($LASTEXITCODE -eq 0) {
        Log-Success "Pods prontos"
    } else {
        Log-Warn "Timeout aguardando pods"
    }
}

Write-Host ""
kubectl get all -n fcg-infra