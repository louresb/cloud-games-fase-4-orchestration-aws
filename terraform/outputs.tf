# ECR
output "ecr_repository_urls" {
  description = "ECR repository URLs by service."
  value       = { for k, repo in aws_ecr_repository.this : k => repo.repository_url }
}

# EKS
output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint."
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_oidc_provider_arn" {
  description = "OIDC provider ARN used for IRSA."
  value       = aws_iam_openid_connect_provider.eks.arn
}

# Redis
output "redis_primary_endpoint" {
  description = "ElastiCache Redis primary endpoint."
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

# OpenSearch
output "opensearch_endpoint" {
  description = "OpenSearch domain HTTPS endpoint."
  value       = aws_opensearch_domain.games.endpoint
}

# DynamoDB
output "dynamodb_audit_table_name" {
  description = "Name of the DynamoDB audit events table."
  value       = aws_dynamodb_table.audit_events.name
}

output "dynamodb_audit_table_arn" {
  description = "ARN of the DynamoDB audit events table."
  value       = aws_dynamodb_table.audit_events.arn
}

# Secrets Manager
output "secrets_manager_arn" {
  description = "ARN of the bundled FCG secret consumed by ExternalSecrets."
  value       = aws_secretsmanager_secret.fcg.arn
}

# IRSA roles
output "irsa_audit_role_arn" {
  description = "IAM role ARN for the audit-sa Kubernetes ServiceAccount."
  value       = aws_iam_role.audit.arn
}

output "irsa_service_role_arns" {
  description = "IAM role ARNs for the users/catalog/payments/notifications Kubernetes ServiceAccounts."
  value       = { for k, role in aws_iam_role.common : k => role.arn }
}

# Optional ECS runtime
output "ecs_cluster_name" {
  description = "Optional ECS cluster for the Notifications worker."
  value       = aws_ecs_cluster.main.name
}

output "main_sqs_queue_url" {
  description = "Main SQS queue used by payment-notification flow."
  value       = aws_sqs_queue.payment_notification.url
}

output "main_sqs_queue_arn" {
  description = "Main SQS queue ARN."
  value       = aws_sqs_queue.payment_notification.arn
}
