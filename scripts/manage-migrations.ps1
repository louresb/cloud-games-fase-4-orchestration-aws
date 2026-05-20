<#
.SYNOPSIS
    Script auxiliar na criação das migrations do EFCore
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet("users", "catalog", "payments", "notifications")]
    [string]$ServicoEspecifico,

    [Parameter(Mandatory=$true, Position=1)]
    [ValidateSet("add", "update", "remove")]
    [string]$Comando,

    [Parameter(Mandatory=$false, Position=2)]
    [string]$NomeMigration # Opcional: Nome da migration para o comando "add"
)

$caminhoRaiz = "."
$caminhoProjeto = ".\src\Fiap.CloudGames.Infrastructure"
$caminhoProjetoInicial = "."

switch ($ServicoEspecifico) {
    "users" {
        $caminhoRaiz = "..\cloud-games-fase-4-users"
        $caminhoProjetoInicial = ".\src\Fiap.CloudGames.API"
    }
    "catalog" {
        $caminhoRaiz = "..\cloud-games-fase-4-catalog"
        $caminhoProjetoInicial = ".\src\Fiap.CloudGames.API"
    }
    "payments" {
        $caminhoRaiz = "..\cloud-games-fase-4-payments"
        $caminhoProjetoInicial = ".\src\Fiap.CloudGames.Worker"
    }
    "notifications" {
        Write-Host "Serviço $ServicoEspecifico não armazena dados" -ForegroundColor Red
        exit 1
        # $caminhoRaiz = "..\cloud-games-fase-4-notifications"
        # $caminhoProjetoInicial = ".\src\Fiap.CloudGames.Worker"
    }
    default {
        Write-Host "Serviço desconhecido: $ServicoEspecifico" -ForegroundColor Red
        exit 1
    }
}

Push-Location $caminhoRaiz

try {
    
    dotnet tool restore

    switch ($Comando) {
        "add" {
            if (-not $NomeMigration) {
                Write-Host "Por favor, forneça o nome da migration para o comando 'add'." -ForegroundColor Red
                exit 1
            }
            dotnet tool run dotnet-ef -- migrations add $NomeMigration --project $caminhoProjeto --startup-project $caminhoProjetoInicial --context AppDbContext
        }
        "update" {
            dotnet tool run dotnet-ef -- database update --project $caminhoProjeto --startup-project $caminhoProjetoInicial --context AppDbContext
        }
        "remove" {
            dotnet tool run dotnet-ef -- migrations remove --project $caminhoProjeto --startup-project $caminhoProjetoInicial --context AppDbContext
        }
        default {
            Write-Host "Comando desconhecido: $Comando" -ForegroundColor Red
            exit 1
        }
    }
} finally {
    Pop-Location
}
