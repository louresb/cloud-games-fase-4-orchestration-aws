<#
.SYNOPSIS
    Orquestrador CloudGames Multi-Serviços
#>

param (
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet("up", "down", "restart", "logs")]
    [string]$Comando,

    [Parameter(Mandatory=$false, Position=1)]
    [ValidateSet("infra", "users", "catalog", "payments", "notifications")]
    [string]$ServicoEspecifico # Opcional: Para ver logs de apenas um serviço
)

# --- CONFIGURAÇÃO ---

# Arquivo de Infraestrutura (Sempre o primeiro a subir e último a descer)
$InfraFile = "docker-compose.infra.yaml"

# Lista de Microsserviços (Adicione seus novos arquivos aqui!)
$AppFiles = @(
    "docker-compose.users.yaml"
    , "docker-compose.catalog.yaml"
    , "docker-compose.payments.yaml"
    , "docker-compose.notifications.yaml"
)

# --- FUNÇÕES ---
function Log-Info ($Message) { Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor Cyan }
function Log-Warn ($Message) { Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor Yellow }
function Log-Success ($Message) { Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor Green }

# --- EXECUÇÃO ---
switch ($Comando) {
    "up" {
        Log-Info "🚀 Iniciando ambiente CloudGames..."
        
        # 1. Sobe a Infra
        Log-Info "--- [1/2] Infraestrutura ---"
        docker-compose -f $InfraFile up -d

        # 2. Sobe cada Microsserviço da lista
        Log-Info "--- [2/2] Microsserviços ---"
        foreach ($file in $AppFiles) {
            # Verifica se o arquivo existe para não dar erro
            if (Test-Path $file) {
                Write-Host "Subindo: $file" -ForegroundColor Gray
                docker-compose -f $file up -d --build
            } else {
                Log-Warn "Aviso: Arquivo '$file' não encontrado. Pulando..."
            }
        }

        Log-Success "✅ Todo o ambiente foi iniciado!"
    }

    "down" {
        Log-Warn "🛑 Parando ambiente..."

        # 1. Derruba Microsserviços (Ordem inversa não é estritamente necessária aqui, mas é boa prática)
        Log-Warn "--- [1/2] Parando Serviços ---"
        foreach ($file in $AppFiles) {
            if (Test-Path $file) {
                Write-Host "Parando: $file" -ForegroundColor Gray
                docker-compose -f $file down
            }
        }

        # 2. Derruba Infra
        Log-Warn "--- [2/2] Parando Infraestrutura ---"
        docker-compose -f $InfraFile down

        Log-Success "✅ Ambiente desligado."
    }

    "restart" {
        # Reinicia tudo chamando as funções acima
        & $MyInvocation.MyCommand.Path down
        & $MyInvocation.MyCommand.Path up
    }
    
    "logs" {
        if ([string]::IsNullOrEmpty($ServicoEspecifico)) {
            Log-Warn "⚠️  Para ver logs, especifique qual arquivo ou use o docker-compose direto."
            Log-Info "Exemplo: ./docker-compose-commands.ps1 logs docker-compose.users.yaml"
            Log-Info "Ou use o comando nativo: docker logs -f <nome_do_container>"
        } else {
            docker-compose -f "docker-compose.$ServicoEspecifico.yaml" logs -f
        }
    }
}