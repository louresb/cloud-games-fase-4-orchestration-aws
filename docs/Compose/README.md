# Como rodar o projeto com Docker Compose

## Pré-requisitos

- Git instalado na sua máquina. Você pode baixar o Git [aqui](https://git-scm.com/downloads).
- Docker instalado na sua máquina. Você pode baixar o Docker [aqui](https://www.docker.com/get-started).
- DBeaver ou outro cliente de banco de dados compatível com SQL Server. Você pode baixar o DBeaver [aqui](https://dbeaver.io/download/).

## Executando a aplicação

1. Crie uma pasta para agrupar os repositórios e navegue até ela no terminal.
   ```powershell
   mkdir 'tech-challenge-fase-4'
   cd '.\tech-challenge-fase-4\'
   ```

2. Clonar os repositórios (crie uma pasta e clone todos dentro dela):
   ```powershell
   git clone https://github.com/louresb/cloud-games-fase-4-orchestration-aws.git
   git clone https://github.com/louresb/cloud-games-fase-4-users.git
   git clone https://github.com/louresb/cloud-games-fase-4-catalog.git
   git clone https://github.com/louresb/cloud-games-fase-4-notifications.git
   git clone https://github.com/louresb/cloud-games-fase-4-payments.git
   git clone https://github.com/louresb/cloud-games-fase-4-audit.git
   ```

3. Navegar até o diretório de orquestração:
   ```powershell
   cd .\cloud-games-fase-4-orchestration-aws\
   ```

4. Configurar as variáveis de ambiente

   Criar um arquivo `.env` na raiz do diretório de orquestração baseado no arquivo `.env.example` e configurar as variáveis de ambiente conforme necessário.
   > Obs: não comite o arquivo `.env` no controle de versão, pois ele pode conter informações sensíveis.

   Configurar o `client-secrets` de cada microsserviço. Para facilitar, rode o script abaixo para cada microsserviço:
   ```powershell
   # service_name = users|catalog|payments|notifications
   .\scripts\open-user-secrets.ps1 service_name
   ```

   > Obs: siga as configurações contidas no `environment` do respectivo `docker-compose.{users|catalog|payments|notifications}.yaml`.

5. Subir os containers com Docker Compose

   Rodar o script para subir todos os Docker Composes:
   ```powershell
   .\scripts\docker-compose-commands.ps1 up
   ```

   Se precisar parar os containers, rode:
   ```powershell
   .\scripts\docker-compose-commands.ps1 down
   ```

   Se precisar ver os logs de algum docker-compose específico, rode:
   ```powershell
   # compose_name = infra|users|catalog|payments|notifications
   .\scripts\docker-compose-commands.ps1 logs compose_name
   ```

6. Acessar as ferramentas e serviços:

   Acessar o DBeaver e conectar ao SQL Server:
   - Host: localhost
   - Porta: 1433
   - Usuário: sa
   - Senha: (Senha configurada na key `SQL_PASSWORD` do `.env`)
     > Obs: os bancos de dados serão criados automaticamente na primeira execução dos microsserviços, junto com as tabelas e dados iniciais (seed).

   Acessar o RabbitMQ Management:
   - URL: http://localhost:15672
   - Usuário: (Usuário configurado na key `RABBIT_USER` do `.env`)
   - Senha: (Senha configurada na key `RABBIT_PASS` do `.env`)

   Acessar o Grafana:
   - URL: http://localhost:3000
   - Usuário: (Usuário configurado na key `GRAFANA_USER` do `.env`)
   - Senha: (Senha configurado na key `GRAFANA_PASSWORD` do `.env`)
     > Obs: será necessário configurar o Data Source do Loki manualmente na primeira vez que acessar o Grafana.

   Acessar o Swagger de cada microsserviço:
   - `Users API`: http://localhost:5000/swagger/index.html
     > Usar o endpoint `/api/Auth/login` para gerar o token JWT com os dados do administrador criado no seed.
   - `Catalog API`: http://localhost:5001/swagger/index.html
     > Usar o token JWT obtido no `Users API`
