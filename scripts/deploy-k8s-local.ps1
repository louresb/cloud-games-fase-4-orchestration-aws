$ErrorActionPreference = "Stop"

$root = "C:\Users\bruno\dev"
$orch = Join-Path $root "cloud-games-fase-4-orchestration-aws"

$SqlPassword = if ($env:SQL_PASSWORD) { $env:SQL_PASSWORD } else { "Your_password123" }
$JwtSecret = if ($env:JWT_SECRET) { $env:JWT_SECRET } else { "dev-only-change-me-32-characters-min" }
$PaymentWebhookApiKey = if ($env:PAYMENT_WEBHOOK_API_KEY) { $env:PAYMENT_WEBHOOK_API_KEY } else { "dev-payment-key" }
$RabbitUser = if ($env:RABBITMQ_USERNAME) { $env:RABBITMQ_USERNAME } else { "guest" }
$RabbitPassword = if ($env:RABBITMQ_PASSWORD) { $env:RABBITMQ_PASSWORD } else { "guest" }
$AdminPassword = if ($env:ADMIN_USER_PASSWORD) { $env:ADMIN_USER_PASSWORD } else { "Admin123!" }

function Apply-Secret {
  param(
    [string] $Namespace,
    [string] $Name,
    [string[]] $Literals
  )

  $args = @("-n", $Namespace, "create", "secret", "generic", $Name) + $Literals + @("--dry-run=client", "-o", "yaml")
  & kubectl @args | kubectl apply -f -
}

kubectl apply -f (Join-Path $orch "k8s\namespaces.yaml")

Apply-Secret "fcg-infra" "rabbitmq-secret" @(
  "--from-literal=RABBITMQ_DEFAULT_USER=$RabbitUser",
  "--from-literal=RABBITMQ_DEFAULT_PASS=$RabbitPassword"
)

Apply-Secret "fcg-infra" "mssql-secret" @(
  "--from-literal=MSSQL_SA_PASSWORD=$SqlPassword"
)

Apply-Secret "fcg-apps" "users-secret" @(
  "--from-literal=ConnectionStrings__DefaultConnection=Server=sqlserver-service.fcg-infra.svc.cluster.local,1433;Database=UsersDb;User Id=sa;Password=$SqlPassword;TrustServerCertificate=True;Encrypt=False;",
  "--from-literal=RabbitMq__UserName=$RabbitUser",
  "--from-literal=RabbitMq__Password=$RabbitPassword",
  "--from-literal=Jwt__Secret=$JwtSecret",
  "--from-literal=AdminUser__Name=Administrador",
  "--from-literal=AdminUser__Email=adm@fcg.com",
  "--from-literal=AdminUser__Password=$AdminPassword",
  "--from-literal=AdminUser__Role=Administrator",
  "--from-literal=AdminUser__Status=Active",
  "--from-literal=AdminUser__EmailConfirmed=true"
)

Apply-Secret "fcg-apps" "catalog-secret" @(
  "--from-literal=ConnectionStrings__DefaultConnection=Server=sqlserver-service.fcg-infra.svc.cluster.local,1433;Database=CatalogDb;User Id=sa;Password=$SqlPassword;TrustServerCertificate=True;Encrypt=False;",
  "--from-literal=RabbitMq__UserName=$RabbitUser",
  "--from-literal=RabbitMq__Password=$RabbitPassword",
  "--from-literal=Jwt__Secret=$JwtSecret"
)

Apply-Secret "fcg-apps" "payments-secret" @(
  "--from-literal=ConnectionStrings__DefaultConnection=Server=sqlserver-service.fcg-infra.svc.cluster.local,1433;Database=PaymentsDb;User Id=sa;Password=$SqlPassword;TrustServerCertificate=True;Encrypt=False;",
  "--from-literal=RabbitMq__UserName=$RabbitUser",
  "--from-literal=RabbitMq__Password=$RabbitPassword",
  "--from-literal=PaymentSettings__WebhookApiKey=$PaymentWebhookApiKey"
)

Apply-Secret "fcg-apps" "notifications-secret" @(
  "--from-literal=RabbitMq__UserName=$RabbitUser",
  "--from-literal=RabbitMq__Password=$RabbitPassword"
)

Apply-Secret "fcg-apps" "audit-secret" @(
  "--from-literal=RabbitMq__UserName=$RabbitUser",
  "--from-literal=RabbitMq__Password=$RabbitPassword",
  "--from-literal=DynamoDb__ServiceUrl=http://dynamodb-local.fcg-infra.svc.cluster.local:8000"
)

kubectl apply -f (Join-Path $orch "k8s\rabbitmq-pvc.yaml")
kubectl apply -f (Join-Path $orch "k8s\rabbitmq-deployment.yaml")
kubectl apply -f (Join-Path $orch "k8s\rabbitmq-service.yaml")
kubectl apply -f (Join-Path $orch "k8s\sqlserver-pvc.yaml")
kubectl apply -f (Join-Path $orch "k8s\sqlserver-deployment.yaml")
kubectl apply -f (Join-Path $orch "k8s\sqlserver-service.yaml")
kubectl apply -f (Join-Path $orch "k8s\redis-deployment.yaml")
kubectl apply -f (Join-Path $orch "k8s\opensearch-deployment.yaml")
kubectl apply -f (Join-Path $orch "k8s\dynamodb-local-deployment.yaml")
kubectl apply -f (Join-Path $orch "k8s\loki-configmap.yaml")
kubectl apply -f (Join-Path $orch "k8s\loki-pvc.yaml")
kubectl apply -f (Join-Path $orch "k8s\loki-deployment.yaml")
kubectl apply -f (Join-Path $orch "k8s\loki-service.yaml")
kubectl apply -f (Join-Path $orch "k8s\grafana-configmap.yaml")
kubectl apply -f (Join-Path $orch "k8s\grafana-deployment.yaml")
kubectl apply -f (Join-Path $orch "k8s\grafana-service.yaml")

foreach ($svc in @("users", "catalog", "payments", "notifications", "audit")) {
  $dir = Join-Path $root "cloud-games-fase-4-$svc\k8s"
  kubectl apply -f $dir
}

kubectl apply -f (Join-Path $orch "k8s\fcg-ingress.yaml")
kubectl -n fcg-apps get pods,svc,hpa,ingress
