# Aderencia ao PDF - Fase 4

| Requisito | Implementacao | Evidencia |
|---|---|---|
| Kubernetes gerenciado | Amazon EKS com managed node group e OIDC/IRSA | `terraform/eks.tf`, `terraform/iam-irsa.tf` |
| CI/CD | GitHub Actions por servico: build, test, Docker build, push ECR, deploy K8s | `.github/workflows/deploy.yml` nos 5 repos |
| Redis | Redis local para demo e ElastiCache na AWS | `k8s/redis-deployment.yaml`, `terraform/elasticache.tf`, `GameService.cs` |
| Elasticsearch/OpenSearch | OpenSearch local e Amazon OpenSearch Service | `k8s/opensearch-deployment.yaml`, `terraform/opensearch.tf`, `OpenSearchGameSearchService.cs` |
| NoSQL | DynamoDB para Audit | `terraform/dynamodb.tf`, `DynamoDbAuditRepository.cs` |
| Registry privado | Amazon ECR privado para users/catalog/payments/notifications/audit | `terraform/ecr.tf` |
| LoadBalancer/Ingress | Ingress central ALB-ready com fallback NGINX/kind | `k8s/fcg-ingress.yaml` |
| Secrets sem hardcode | AWS Secrets Manager + External Secrets Operator; templates locais sem segredo real | `terraform/secrets-manager.tf`, `k8s/external-secrets-operator.yaml` |
| Rolling Update | Deployments com `maxUnavailable: 0` e `maxSurge: 1` | `k8s/*-deployment.yaml` dos servicos |
| Cloud-native | EKS, HPA, IRSA, ECR, managed data services, logs estruturados | Terraform + manifests + Serilog |
| Observabilidade | Serilog, CorrelationId, TenantId em logs; Loki/Grafana local | `Program.cs`, middlewares, `k8s/loki-*`, `k8s/grafana-*` |
| Event-driven | MassTransit/RabbitMQ local, headers TenantId/CorrelationId, consumidores em Notifications e Audit | `Application/*/Consumers`, `MassTransitEventPublisher.cs` |
| Multi-tenant ready | Tenants FIAP/Alura/PM3; TenantId em JWT, eventos, Audit e logs | `Tenants.cs`, `TenantMiddleware.cs`, Audit service |

## Validacoes executadas

- `dotnet build -c Release` em users, catalog, payments, notifications e audit.
- `dotnet test -c Release --no-build` em users, catalog, payments, notifications e audit.
- Docker client encontrado, mas daemon nao estava ativo nesta sessao.
- `kubectl` encontrado, mas nao havia cluster ativo nesta sessao para dry-run server/client com discovery.
- `terraform` nao estava no PATH desta sessao; arquivos estao prontos para `terraform init/plan` no ambiente da demo.

## Observacoes de escopo

- Pagamento real/Pix ficou como gateway mock, conforme prioridade de estabilidade e demo.
- Multi-tenant esta preparado, sem isolamento enterprise completo nesta entrega.
- ECS legado de Notifications permanece no Terraform apenas como compatibilidade; a arquitetura alvo da Fase 4 e EKS.