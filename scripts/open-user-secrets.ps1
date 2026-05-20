<#
.SYNOPSIS
    Script para abrir os secrets do .csproj de um dos services
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet("users", "catalog", "payments", "notifications", "all")]
    [string]$ServicoEspecifico
)

$Servicos=@()

if ($ServicoEspecifico="all") {
    $Servicos = @("users", "catalog", "payments", "notifications")
}
else {
    $Servicos = $($ServicoEspecifico)
}

foreach ($Servico in $Servicos) {

    $caminhoProjeto = "."

    switch ($Servico) {
        "users" {
            $caminhoProjeto = "..\cloud-games-fase-4-users\src\Fiap.CloudGames.API\Fiap.CloudGames.API.csproj"
        }
        "catalog" {
            $caminhoProjeto = "..\cloud-games-fase-4-catalog\src\Fiap.CloudGames.API\Fiap.CloudGames.API.csproj"
        }
        "payments" {
            $caminhoProjeto = "..\cloud-games-fase-4-payments\src\Fiap.CloudGames.Worker\Fiap.CloudGames.Worker.csproj"
        }
        "notifications" {
            $caminhoProjeto = "..\cloud-games-fase-4-notifications\src\Fiap.CloudGames.Worker\Fiap.CloudGames.Worker.csproj"
        }
        default {
            Write-Host "Serviço desconhecido: $Servico" -ForegroundColor Red
            exit 1
        }
    }

    if (Test-Path $caminhoProjeto) {
        # --- Se o arquivo EXISTE, executa a lógica ---
        Write-Host "Arquivo .csproj encontrado! Lendo dados..." -ForegroundColor Green
        
        # Carrega o XML e silencia erros de leitura caso o XML esteja malformado
        try {
            $xml = [xml](Get-Content $caminhoProjeto -ErrorAction Stop)
            
            # Tenta pegar o UserSecretsId (filtra para evitar nulos se houver múltiplos grupos)
            $userSecretsId = $xml.Project.PropertyGroup.UserSecretsId | Where-Object { $_ -ne $null } | Select-Object -First 1

            if ($userSecretsId) {
                Write-Host "Abrindo os secrets do .csproj..." -ForegroundColor Green
                code "$env:APPDATA\Microsoft\UserSecrets\$userSecretsId\secrets.json"
            } else {
                Write-Warning "O arquivo existe, mas não possui a tag <UserSecretsId>."
            }
        }
        catch {
            Write-Error "Erro ao ler o conteúdo do arquivo. Verifique se é um XML válido."
        }
    } else {
        Write-Error "O arquivo .csproj não foi encontrado no caminho: $caminhoProjeto"
        return 
    }
}