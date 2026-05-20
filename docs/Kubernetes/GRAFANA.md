## Grafana

### Secret

| Arquivo | `k8s\grafana-secret.yaml` |
|---|---|
| apiVersion | `v1` |
| kind | `Secret` |
| metadata.name | `grafana-secret` |
| metadata.namespace | `fcg-infra` |
| metadata.labels | `app: grafana` |
| type / data | Utiliza `stringData` com `GF_SECURITY_ADMIN_USER` e `GF_SECURITY_ADMIN_PASSWORD` (ex.: `admin`). Não commitar segredos reais ao repositório. |

### ConfigMap

| Arquivo | `k8s\grafana-configmap.yaml` |
|---|---|
| apiVersion | `v1` |
| kind | `ConfigMap` |
| metadata.name | `grafana-datasources` |
| metadata.namespace | `fcg-infra` |
| metadata.labels | `app: grafana` |
| data.loki-datasource.yaml | Provisiona a datasource `Loki` com `url: http://loki-service:3100`, `access: proxy` e `isDefault: true` (formato de provisionamento automático de datasources). |

### Service

| Arquivo | `k8s\grafana-service.yaml` |
|---|---|
| apiVersion | `v1` |
| kind | `Service` |
| metadata.name | `grafana-service` |
| metadata.namespace | `fcg-infra` |
| metadata.labels | `app: grafana` |
| spec.type | `NodePort` (expondo porta no nó) |
| spec.selector | `app: grafana` |
| spec.ports[0].port | `3000` |
| spec.ports[0].targetPort | `3000` |
| spec.ports[0].nodePort | `30300` |

### Deployment

| Arquivo | `k8s\grafana-deployment.yaml` |
|---|---|
| apiVersion | `apps/v1` |
| kind | `Deployment` |
| metadata.name | `grafana-deployment` |
| metadata.namespace | `fcg-infra` |
| metadata.labels | `app: grafana` |
| spec.replicas | `1` |
| spec.selector.matchLabels | `app: grafana` |
| template.spec.containers[0].name | `grafana` |
| template.spec.containers[0].image | `grafana/grafana:latest` |
| template.spec.containers[0].ports | containerPort `3000` |
| template.spec.containers[0].resources.requests | memory `256Mi`, cpu `200m` |
| template.spec.containers[0].resources.limits | memory `512Mi`, cpu `500m` |
| template.spec.containers[0].env | `GF_SECURITY_ADMIN_USER` e `GF_SECURITY_ADMIN_PASSWORD` via Secret `grafana-secret` |
| template.spec.containers[0].volumeMounts | `grafana-provisioning` montado em `/etc/grafana/provisioning/datasources` (readOnly: true) |
| template.spec.containers[0].readinessProbe | httpGet `/api/health` porta `3000`, `initialDelaySeconds: 5`, `periodSeconds: 10` |
| template.spec.volumes | `grafana-provisioning` proveniente do ConfigMap `grafana-datasources` |
