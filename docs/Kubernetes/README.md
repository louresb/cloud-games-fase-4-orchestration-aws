# Como rodar o projeto com Kubernetes

## Pré-requisitos

- Git instalado na sua máquina. Você pode baixar o Git [aqui](https://git-scm.com/downloads).
- Docker instalado na sua máquina. Você pode baixar o Docker [aqui](https://www.docker.com/get-started).
  - Note que o Docker Desktop já vem com o Kubernetes integrado, então você pode utilizá-lo para rodar o cluster localmente.
- DBeaver ou outro cliente de banco de dados compatível com SQL Server. Você pode baixar o DBeaver [aqui](https://dbeaver.io/download/).

## Índice
- Configurações
  - [Namespace](./NAMESPACE.md)
  - [SQL Server](./SQLSERVER.md)
  - [RabbitMQ](./RABBITMQ.md)
  - [Loki](./LOKI.md)
  - [Grafana](./GRAFANA.md)
- [Comandos úteis](#comandos-uteis)

> Atenção! 
>
> Os manifestos de secrets `k8s\*-secret.yaml` não estão incluídos no repositório (e é ignorado pelo `.gitignore`) por conter informações sensíveis, como senhas.
>
> Você pode copiar o seu respectivo arquivo de exemplo `k8s\templates\\*-secret.yaml` e ajustar os valores.

### Comandos úteis

- Aplicar todos os manifestos (na ordem correta):
  ```bash
  kubectl apply -f k8s/fcg-infra-namespace.yaml
  kubectl apply -f k8s/sqlserver-secret.yaml
  kubectl apply -f k8s/sqlserver-pvc.yaml
  kubectl apply -f k8s/sqlserver-service.yaml
  kubectl apply -f k8s/sqlserver-deployment.yaml
  kubectl apply -f k8s/rabbitmq-secret.yaml
  kubectl apply -f k8s/rabbitmq-pvc.yaml
  kubectl apply -f k8s/rabbitmq-service.yaml
  kubectl apply -f k8s/rabbitmq-deployment.yaml
  kubectl apply -f k8s/loki-pvc.yaml
  kubectl apply -f k8s/loki-service.yaml
  kubectl apply -f k8s/loki-deployment.yaml
  kubectl apply -f k8s/grafana-secret.yaml
  kubectl apply -f k8s/grafana-configmap.yaml
  kubectl apply -f k8s/grafana-service.yaml
  kubectl apply -f k8s/grafana-deployment.yaml
  ```

 - Opção 2: Usar script automatizado

   Para aplicar todos os manifestos de uma vez: 
    ```bash
    # Aplicar todos os manifestos
    .\scripts\k8s-apply-all.ps1
    
    # Ou sem aguardar pods ficarem prontos
    .\scripts\k8s-apply-all.ps1 -SkipWait
    ```

    Para remover todos os recursos:
    
    ```bash
    # Remover todos os recursos
    .\scripts\k8s-delete-all.ps1
    ```

- Verificar serviços:
  ```bash
  kubectl get services -n fcg-infra
  ```
  
- Verificar pods:
  ```bash
  kubectl get pods -n fcg-infra
  ```
  
- Verificar detalhes de um pod:
  ```bash
  kubectl describe pod <nome-do-pod> -n fcg-infra
  ```
  
- Verificar logs de um pod:
  ```bash
  ## Logs de um pod específico:
  kubectl logs <nome-do-pod> -n fcg-infra
  ## Logs de um deployment (pega o pod automaticamente):
  kubectl logs deployment/<nome-do-deployment> -n fcg-infra
  ## Logs em tempo real:
  kubectl logs -f <nome-do-pod> -n fcg-infra
  ## Últimas 100 linhas:
  kubectl logs <nome-do-pod> -n fcg-infra --tail=100
  ```
  
- Acessar um pod via shell:
  ```bash
  ## Acessar um pod específico:
  kubectl exec -it <nome-do-pod> -n fcg-infra -- /bin/bash
  ## Acessar um deployment (pega o pod automaticamente):
  kubectl exec -it deployment/<nome-do-deployment> -n fcg-infra -- /bin/bash
  ```

- Resetar o deployment (força reinício):
  ```bash
  kubectl rollout restart deployment/<nome-do-deployment> -n fcg-infra
  ```

- Remover namespace (remove todos os recursos dentro do namespace):
  ```bash
  kubectl delete namespace fcg-infra
  ```
