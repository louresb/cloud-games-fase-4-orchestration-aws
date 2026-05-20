# Roteiro de demo - FIAP Cloud Games Fase 4

Tempo alvo: 8 a 12 minutos.

## 1. Abrir arquitetura

Mostrar `README.md` e destacar:

- AWS-first e Kubernetes-first com EKS.
- Cinco servicos da fase anterior evoluidos + novo Audit.
- Redis, OpenSearch e DynamoDB cobrindo requisitos do PDF.
- Multi-tenant ready: FIAP, Alura e PM3.

## 2. Validar build e testes

```powershell
cd C:\Users\bruno\dev\cloud-games-fase-4-orchestration-aws
.\scripts\validate-phase4.ps1
```

Resultado esperado:

- Users: 30 testes.
- Catalog: 21 testes.
- Payments: 20 testes.
- Notifications: 1 teste.
- Audit: 2 testes.

## 3. Subir dependencias locais

```powershell
copy .env.example .env
docker compose -f docker-compose.fase4.yaml up -d
docker compose -f docker-compose.fase4.yaml ps
```

Mostrar:

- RabbitMQ: http://localhost:15672
- Grafana: http://localhost:3000
- OpenSearch health: http://localhost:9200/_cluster/health
- DynamoDB Local na porta 8000

## 4. Demonstrar Kubernetes

Com Kind/minikube/EKS ja ativo:

```powershell
.\scripts\deploy-k8s-local.ps1
kubectl -n fcg-apps get pods,svc,hpa
kubectl -n fcg-apps describe ingress fcg-ingress
```

Evidencias:

- Deployments com RollingUpdate.
- HPAs por servico.
- Ingress central para Users, Catalog, Payments e Audit.
- Redis/OpenSearch/DynamoDB local em `fcg-infra` para demo.

## 5. Users + TenantId no JWT

```powershell
kubectl -n fcg-apps port-forward svc/users-service 8080:80
```

Em outro terminal:

```bash
curl -X POST http://localhost:8080/api/users/register \
  -H "X-Tenant-Id: Alura" \
  -H "Content-Type: application/json" \
  -d '{"name":"Demo User","email":"demo@alura.com","password":"D3mo!123","tenantId":"Alura"}'

curl -X POST http://localhost:8080/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@alura.com","password":"D3mo!123"}'
```

Decodificar o JWT e apontar a claim `tenant_id`.

## 6. Catalog: Redis + OpenSearch

```powershell
kubectl -n fcg-apps port-forward svc/catalog-service 8081:80
```

Demonstrar:

- `GET /api/games` duas vezes e observar cache HIT nos logs.
- `GET /api/games/search?q=holow%20knihgt&tenantId=FIAP` para busca fuzzy.
- OpenSearch com indice `games`.

## 7. Payments + Notifications + Audit

```powershell
kubectl -n fcg-apps port-forward svc/payments-service 8082:80
kubectl -n fcg-apps port-forward svc/audit-svc 8084:80
```

Executar webhook mock de pagamento e consultar audit:

```bash
curl -X POST http://localhost:8082/api/webhooks/gateway-notification \
  -H "X-Tenant-Id: PM3" \
  -H "X-API-Key: <dev-key>" \
  -H "Content-Type: application/json" \
  -d '{"paymentTransactionId":"tx_demo","status":"success"}'

curl "http://localhost:8084/api/audit?tenantId=PM3&limit=5"
curl "http://localhost:8084/api/audit/correlation/<correlation-id>"
```

Mostrar que Audit salva:

- `TenantId`
- `CorrelationId`
- `EventType`
- `Payload`
- `Timestamp`

## 8. Terraform e CI/CD

```powershell
cd terraform
terraform init
terraform plan
```

Se Terraform nao estiver instalado na maquina da demo, abrir os arquivos:

- `terraform/eks.tf`
- `terraform/ecr.tf`
- `terraform/elasticache.tf`
- `terraform/opensearch.tf`
- `terraform/dynamodb.tf`
- `terraform/secrets-manager.tf`

Mostrar tambem `.github/workflows/deploy.yml` de qualquer servico: build, test, Docker, ECR e rollout K8s.

## Checklist rapido

- [ ] Build/test verde nos cinco servicos.
- [ ] JWT com `tenant_id`.
- [ ] Catalog usando Redis cache.
- [ ] Catalog usando OpenSearch fuzzy search.
- [ ] Audit salvando eventos no DynamoDB.
- [ ] K8s com Ingress, HPA e RollingUpdate.
- [ ] Terraform cobrindo EKS/ECR/Redis/OpenSearch/DynamoDB/Secrets.
- [ ] GitHub Actions cobrindo CI/CD ate rollout.