## RabbitMQ

### Secret

| Arquivo | `k8s\rabbitmq-secret.yaml` |
|---|---|
| apiVersion | `v1` |
| kind | `Secret` |
| metadata.name | `rabbitmq-secret` |
| metadata.namespace | `fcg-infra` |
| metadata.labels | `app: rabbitmq` |
| type / data | Utiliza `stringData` com as chaves `RABBITMQ_DEFAULT_USER` e `RABBITMQ_DEFAULT_PASS` (`guest` no exemplo). Não commitar segredos reais ao repositório. |

### Persistent Volume Claim (PVC)

| Arquivo | `k8s\rabbitmq-pvc.yaml` |
|---|---|
| apiVersion | `v1` |
| kind | `PersistentVolumeClaim` |
| metadata.name | `rabbitmq-pvc` |
| metadata.namespace | `fcg-infra` |
| metadata.labels | `app: rabbitmq` |
| spec.accessModes | `ReadWriteOnce` |
| spec.resources.requests.storage | `5Gi` |

### Service

| Arquivo | `k8s\rabbitmq-service.yaml` |
|---|---|
| apiVersion | `v1` |
| kind | `Service` |
| metadata.name | `rabbitmq-service` |
| metadata.namespace | `fcg-infra` |
| metadata.labels | `app: rabbitmq` |
| spec.type | `NodePort` (expondo portas no nó) |
| spec.selector | `app: rabbitmq` (direciona para o Deployment) |
| spec.ports[0].name | `amqp` |
| spec.ports[0].port | `5672` |
| spec.ports[0].targetPort | `5672` |
| spec.ports[0].nodePort | `31572` |
| spec.ports[1].name | `management` |
| spec.ports[1].port | `15672` |
| spec.ports[1].targetPort | `15672` |
| spec.ports[1].nodePort | `31672` |

### Deployment

| Arquivo | `k8s\rabbitmq-deployment.yaml` |
|---|---|
| apiVersion | `apps/v1` |
| kind | `Deployment` |
| metadata.name | `rabbitmq-deployment` |
| metadata.namespace | `fcg-infra` |
| metadata.labels | `app: rabbitmq` |
| spec.replicas | `1` |
| spec.selector.matchLabels | `app: rabbitmq` |
| template.spec.containers[0].name | `rabbitmq` |
| template.spec.containers[0].image | `rabbitmq:4-management` |
| template.spec.containers[0].ports | containerPort `5672`, `15672` |
| template.spec.containers[0].resources.requests | memory `512Mi`, cpu `500m` |
| template.spec.containers[0].resources.limits | memory `1Gi`, cpu `1000m` |
| template.spec.containers[0].env | `RABBITMQ_DEFAULT_USER` e `RABBITMQ_DEFAULT_PASS` via Secret `rabbitmq-secret` |
| template.spec.containers[0].volumeMounts | `rabbitmq-data` montado em `/var/lib/rabbitmq` |
| template.spec.volumes | `rabbitmq-data` ligado ao `persistentVolumeClaim.claimName: rabbitmq-pvc` |
