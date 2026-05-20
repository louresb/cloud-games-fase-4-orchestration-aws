## Loki

### Persistent Volume Claim (PVC)

| Arquivo | `k8s\loki-pvc.yaml` |
|---|---|
| apiVersion | `v1` |
| kind | `PersistentVolumeClaim` |
| metadata.name | `loki-pvc` |
| metadata.namespace | `fcg-infra` |
| metadata.labels | `app: loki` |
| spec.accessModes | `ReadWriteOnce` |
| spec.resources.requests.storage | `5Gi` |

### Service

| Arquivo | `k8s\loki-service.yaml` |
|---|---|
| apiVersion | `v1` |
| kind | `Service` |
| metadata.name | `loki-service` |
| metadata.namespace | `fcg-infra` |
| metadata.labels | `app: loki` |
| spec.type | `ClusterIP` (serviço interno ao cluster) |
| spec.selector | `app: loki` |
| spec.ports[0].port | `3100` |
| spec.ports[0].targetPort | `3100` |

### Deployment

| Arquivo | `k8s\loki-deployment.yaml` |
|---|---|
| apiVersion | `apps/v1` |
| kind | `Deployment` |
| metadata.name | `loki-deployment` |
| metadata.namespace | `fcg-infra` |
| metadata.labels | `app: loki` |
| spec.replicas | `1` |
| spec.selector.matchLabels | `app: loki` |
| template.spec.containers[0].name | `loki` |
| template.spec.containers[0].image | `grafana/loki:latest` |
| template.spec.containers[0].ports | containerPort `3100` |
| template.spec.containers[0].resources.requests | memory `1Gi`, cpu `500m` |
| template.spec.containers[0].resources.limits | memory `2Gi`, cpu `1000m` |
| template.spec.containers[0].volumeMounts | `loki-data` montado em `/loki` |
| template.spec.volumes | `loki-data` ligado ao `persistentVolumeClaim.claimName: loki-pvc` |
