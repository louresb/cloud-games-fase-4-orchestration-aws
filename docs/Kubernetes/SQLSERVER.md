## SQL Server

### Secret

| Arquivo | `k8s\sqlserver-secret.yaml` |
|---|---|
| apiVersion | `v1` |
| kind | `Secret` |
| metadata.name | `mssql-secret` |
| metadata.namespace | `fcg-infra` |
| metadata.labels | `app: sqlserver` |
| type / data | Utiliza `stringData` com a chave `MSSQL_SA_PASSWORD` (`YOUR_PASSWORD` no exemplo). Não commitar segredos reais ao repositório. |

### Persistent Volume Claim (PVC)

| Arquivo | `k8s\sqlserver-pvc.yaml` |
|---|---|
| apiVersion | `v1` |
| kind | `PersistentVolumeClaim` |
| metadata.name | `mssql-pvc` |
| metadata.namespace | `fcg-infra` |
| metadata.labels | `app: sqlserver` |
| spec.accessModes | `ReadWriteOnce` |
| spec.resources.requests.storage | `10Gi` |

### Service

| Arquivo | `k8s\sqlserver-service.yaml` |
|---|---|
| apiVersion | `v1` |
| kind | `Service` |
| metadata.name | `sqlserver-service` |
| metadata.namespace | `fcg-infra` |
| metadata.labels | `app: sqlserver` |
| spec.type | `NodePort` (expondo porta no nó) |
| spec.selector | `app: sqlserver` (direciona para o Deployment) |
| spec.ports.port | `1433` (porta do serviço) |
| spec.ports.targetPort | `1433` (porta do container) |
| spec.ports.nodePort | `31433` (porta do nó configurada) |

### Deployment

| Arquivo | `k8s\sqlserver-deployment.yaml` |
|---|---|
| apiVersion | `apps/v1` |
| kind | `Deployment` |
| metadata.name | `sqlserver-deployment` |
| metadata.namespace | `fcg-infra` |
| metadata.labels | `app: sqlserver` |
| spec.replicas | `1` |
| spec.selector.matchLabels | `app: sqlserver` |
| template.spec.containers[0].name | `sqlserver` |
| template.spec.containers[0].image | `mcr.microsoft.com/mssql/server:2022-latest` |
| template.spec.containers[0].ports | containerPort `1433` |
| template.spec.containers[0].resources.requests | memory `2Gi`, cpu `1000m` |
| template.spec.containers[0].resources.limits | memory `4Gi`, cpu `2000m` |
| template.spec.containers[0].env | `ACCEPT_EULA=Y`, `MSSQL_PID=Express`, `MSSQL_SA_PASSWORD` via Secret `mssql-secret` |
| template.spec.containers[0].volumeMounts | `mssql-data` montado em `/var/opt/mssql/data` |
| template.spec.volumes | `mssql-data` ligado ao `persistentVolumeClaim.claimName: mssql-pvc` |
| template.spec.readinessProbe | tcpSocket porta `1433`, `initialDelaySeconds: 30`, `periodSeconds: 10` |
