# AWS Academy Setup - FIAP Cloud Games Fase 4

Este guia descreve a configuracao da Fase 4 usando AWS Academy Learner Lab. A arquitetura entregue continua AWS-first/EKS-first, mas o Academy tem restricoes importantes: as credenciais expiram, o `AWS_SESSION_TOKEN` muda a cada lab e algumas permissoes de IAM/EKS/OpenSearch/ElastiCache podem estar bloqueadas.

## Estrategia recomendada

Use dois trilhos:

1. **Validacao local/Kubernetes**: subir os manifests em Kind, Minikube ou Docker Desktop Kubernetes usando Redis, OpenSearch e DynamoDB Local dos manifests compartilhados.
2. **Validacao AWS**: usar AWS Academy para ECR, DynamoDB e, se o lab permitir, EKS/OpenSearch/ElastiCache via Terraform.

Se o EKS ou Terraform falhar por `AccessDenied`, isso e uma restricao esperada do Academy. O ambiente continua executavel porque os manifests, pipelines, Dockerfiles, NoSQL, Redis, OpenSearch e arquitetura cloud-native estao prontos.

## 1. Iniciar o AWS Academy Lab

1. Abra o Learner Lab.
2. Clique em **Start Lab** e aguarde o indicador ficar verde.
3. Em **AWS Details**, copie:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_SESSION_TOKEN`
4. Use a mesma regiao em tudo. Recomendado: `us-east-1`.

No PowerShell local:

```powershell
$env:AWS_ACCESS_KEY_ID="COLE_AQUI"
$env:AWS_SECRET_ACCESS_KEY="COLE_AQUI"
$env:AWS_SESSION_TOKEN="COLE_AQUI"
$env:AWS_DEFAULT_REGION="us-east-1"
$env:AWS_REGION="us-east-1"

aws sts get-caller-identity
$env:AWS_ACCOUNT_ID=(aws sts get-caller-identity --query Account --output text)
```

## 2. GitHub Secrets e Variables

Configure isso em **cada repo** que voce subir no GitHub:

- `cloud-games-fase-4-users`
- `cloud-games-fase-4-catalog`
- `cloud-games-fase-4-payments`
- `cloud-games-fase-4-notifications`
- `cloud-games-fase-4-audit`

Secrets obrigatorios para AWS Academy:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`

Variables recomendadas:

- `AWS_REGION` = `us-east-1`
- `EKS_CLUSTER` = `cloud-games-dev-eks`
- `K8S_NAMESPACE` = `fcg-apps`

Importante: no AWS Academy os secrets expiram e precisam ser atualizados a cada novo lab.

Para uma conta AWS normal, configure `AWS_DEPLOY_ROLE_ARN`. Os workflows preferem OIDC quando essa secret existe; se estiver vazia, usam as credenciais temporarias do AWS Academy.

## 2.1. Configurar Secrets via script seguro

Nao commite as credenciais do AWS Academy. Elas devem ficar apenas como secrets do GitHub ou variaveis de ambiente locais.

No PowerShell, cole os valores do Learner Lab como variaveis de ambiente:

```powershell
$env:AWS_ACCESS_KEY_ID="COLE_O_ACCESS_KEY_ID"
$env:AWS_SECRET_ACCESS_KEY="COLE_O_SECRET_ACCESS_KEY"
$env:AWS_SESSION_TOKEN="COLE_O_SESSION_TOKEN"
$env:AWS_REGION="us-east-1"
```

Depois, com GitHub CLI autenticado (`gh auth login`), rode:

```powershell
cd C:\Users\bruno\dev\cloud-games-fase-4-orchestration-aws
.\scripts\configure-github-academy-secrets.ps1 -Owner louresb
```

O script configura os secrets `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` e as variables `AWS_REGION`, `EKS_CLUSTER`, `K8S_NAMESPACE` nos repos de servico.
## 3. Criar os repositorios ECR manualmente

Se voce nao for aplicar Terraform, crie os repositorios ECR manualmente:

```powershell
$repos = @(
  "cloud-games-users-svc",
  "cloud-games-catalog-svc",
  "cloud-games-payments-svc",
  "cloud-games-notifications-svc",
  "cloud-games-audit-svc"
)

foreach ($repo in $repos) {
  aws ecr describe-repositories --repository-names $repo 2>$null
  if ($LASTEXITCODE -ne 0) {
    aws ecr create-repository --repository-name $repo --image-scanning-configuration scanOnPush=true
  }
}
```

Login local no ECR:

```powershell
aws ecr get-login-password --region $env:AWS_REGION | docker login --username AWS --password-stdin "$env:AWS_ACCOUNT_ID.dkr.ecr.$env:AWS_REGION.amazonaws.com"
```

## 4. Terraform AWS

O Terraform esta em `terraform/` e descreve EKS, ECR, DynamoDB, OpenSearch, ElastiCache Redis, Secrets Manager e IAM/IRSA.

```powershell
cd C:\Users\bruno\dev\cloud-games-fase-4-orchestration-aws\terraform
copy terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars
terraform init
terraform plan
```

Se o plan/apply falhar em recursos IAM, EKS, OpenSearch ou ElastiCache com `AccessDenied`, siga com a demo local Kubernetes e use ECR/DynamoDB quando disponiveis no lab.

## 5. Kubernetes local ou EKS

Se o EKS existir:

```powershell
aws eks update-kubeconfig --region $env:AWS_REGION --name cloud-games-dev-eks
kubectl get nodes
```

Para execucao local, prefira o script pronto. Ele cria namespaces, secrets locais, RabbitMQ, SQL Server, Redis, OpenSearch, DynamoDB Local, Loki/Grafana e aplica os servicos:

```powershell
cd C:\Users\bruno\dev\cloud-games-fase-4-orchestration-aws
$env:SQL_PASSWORD="Your_password123"
$env:JWT_SECRET="dev-only-change-me-32-characters-min"
$env:PAYMENT_WEBHOOK_API_KEY="dev-payment-key"
.\scripts\deploy-k8s-local.ps1
```

Aplicacao manual da infraestrutura compartilhada, se preferir passo a passo:

```powershell
kubectl apply -f k8s\namespaces.yaml
kubectl apply -f k8s\rabbitmq-pvc.yaml
kubectl apply -f k8s\rabbitmq-deployment.yaml
kubectl apply -f k8s\rabbitmq-service.yaml
kubectl apply -f k8s\sqlserver-pvc.yaml
kubectl apply -f k8s\sqlserver-deployment.yaml
kubectl apply -f k8s\sqlserver-service.yaml
kubectl apply -f k8s\redis-deployment.yaml
kubectl apply -f k8s\opensearch-deployment.yaml
kubectl apply -f k8s\dynamodb-local-deployment.yaml
kubectl apply -f k8s\fcg-ingress.yaml
```

Para EKS real com Secrets Manager:

```powershell
kubectl apply -f k8s\external-secrets-operator.yaml
```

Para execucao rapida sem Secrets Manager, crie Secrets Kubernetes manualmente. Ajuste valores conforme seu ambiente:

```powershell
kubectl -n fcg-apps create secret generic users-secret --from-literal=ConnectionStrings__DefaultConnection="Server=sqlserver-service.fcg-infra.svc.cluster.local,1433;Database=UsersDb;User Id=sa;Password=Your_password123;TrustServerCertificate=True;Encrypt=False;" --from-literal=Jwt__Secret="dev-only-change-me-32-characters-min" --from-literal=RabbitMq__UserName="guest" --from-literal=RabbitMq__Password="guest" --from-literal=AdminUser__Name="Administrador" --from-literal=AdminUser__Email="adm@fcg.com" --from-literal=AdminUser__Password="Admin123!" --from-literal=AdminUser__Role="Administrator" --from-literal=AdminUser__Status="Active" --from-literal=AdminUser__EmailConfirmed="true" --dry-run=client -o yaml | kubectl apply -f -

kubectl -n fcg-apps create secret generic catalog-secret --from-literal=ConnectionStrings__DefaultConnection="Server=sqlserver-service.fcg-infra.svc.cluster.local,1433;Database=CatalogDb;User Id=sa;Password=Your_password123;TrustServerCertificate=True;Encrypt=False;" --from-literal=Jwt__Secret="dev-only-change-me-32-characters-min" --from-literal=RabbitMq__UserName="guest" --from-literal=RabbitMq__Password="guest" --dry-run=client -o yaml | kubectl apply -f -

kubectl -n fcg-apps create secret generic payments-secret --from-literal=ConnectionStrings__DefaultConnection="Server=sqlserver-service.fcg-infra.svc.cluster.local,1433;Database=PaymentsDb;User Id=sa;Password=Your_password123;TrustServerCertificate=True;Encrypt=False;" --from-literal=RabbitMq__UserName="guest" --from-literal=RabbitMq__Password="guest" --from-literal=PaymentSettings__WebhookApiKey="dev-payment-key" --dry-run=client -o yaml | kubectl apply -f -

kubectl -n fcg-apps create secret generic notifications-secret --from-literal=RabbitMq__UserName="guest" --from-literal=RabbitMq__Password="guest" --dry-run=client -o yaml | kubectl apply -f -

kubectl -n fcg-apps create secret generic audit-secret --from-literal=RabbitMq__UserName="guest" --from-literal=RabbitMq__Password="guest" --from-literal=DynamoDb__ServiceUrl="http://dynamodb-local.fcg-infra.svc.cluster.local:8000" --dry-run=client -o yaml | kubectl apply -f -
```

## 6. Build/push/deploy via GitHub Actions

Depois de subir cada pasta para seu GitHub:

1. Configure secrets/variables do item 2.
2. Garanta que os repos ECR existem.
3. Execute o workflow manualmente em **Actions > Build, Push & Deploy > Run workflow**.
4. Se o deploy falhar por EKS inexistente, o build/test e push ECR ainda validam CI/CD e registry privado.

## 7. Checklist de validacao

- `dotnet test` passando nos cinco servicos.
- Dockerfile presente nos cinco servicos.
- Imagens publicadas no ECR.
- Namespace `fcg-apps` criado.
- Redis disponivel.
- OpenSearch disponivel.
- DynamoDB/Audit disponivel.
- Ingress ou LoadBalancer aplicado.
- Eventos contendo `TenantId` e `CorrelationId`.
- Logs estruturados com Serilog/CorrelationId/TenantId.

