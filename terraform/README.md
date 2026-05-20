# Terraform - FIAP Cloud Games Fase 4

Este diretorio contem a infraestrutura AWS da Fase 4.

## Escopo

- Amazon EKS gerenciado com managed node group.
- Amazon ECR privado para users, catalog, payments, notifications e audit.
- ElastiCache Redis para cache do Catalog.
- Amazon OpenSearch para busca fuzzy/read model do Catalog.
- DynamoDB para Audit.
- AWS Secrets Manager para configuracoes sensiveis.
- IAM/IRSA para acesso AWS por service account do Kubernetes.
- SQS e ECS Notifications legado mantidos apenas por compatibilidade.

## Uso

```powershell
copy terraform.tfvars.example terraform.tfvars
# Edite terraform.tfvars com valores reais/sensiveis locais.
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

`terraform.tfvars` e `*.tfstate` sao ignorados pelo Git.

## Arquivos

- `providers.tf`: providers e versoes.
- `main.tf`: composicao e data sources comuns.
- `ecr.tf`: repositorios privados ECR.
- `eks.tf`: EKS + node group.
- `elasticache.tf`: Redis gerenciado.
- `opensearch.tf`: OpenSearch gerenciado.
- `dynamodb.tf`: tabela de Audit.
- `secrets-manager.tf`: segredo compartilhado para External Secrets.
- `iam-irsa.tf`: roles IAM por service account.
- `ecs-notifications.tf`: legado opcional da fase anterior.
- `outputs.tf`: endpoints e ARNs principais.