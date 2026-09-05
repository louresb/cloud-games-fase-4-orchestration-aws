variable "project_name" {
  type        = string
  description = "Project identifier used as a naming prefix."
  default     = "cloud-games"
}

variable "environment" {
  type        = string
  description = "Environment name (for example: dev, staging, prod)."
  default     = "dev"
}

variable "aws_region" {
  type        = string
  description = "AWS region used by the provider."
  default     = "us-east-1"
}

# ---------- ECR ----------

variable "ecr_users_repository_name" {
  type    = string
  default = "cloud-games-users-svc"
}

variable "ecr_payments_repository_name" {
  type    = string
  default = "cloud-games-payments-svc"
}

variable "ecr_notifications_repository_name" {
  type    = string
  default = "cloud-games-notifications-svc"
}

variable "ecr_catalog_repository_name" {
  type    = string
  default = "cloud-games-catalog-svc"
}

variable "ecr_audit_repository_name" {
  type    = string
  default = "cloud-games-audit-svc"
}

# ---------- Optional SQS runtime ----------

variable "main_sqs_queue_name" {
  type    = string
  default = "payment-notification-flow"
}

variable "main_sqs_queue_name_prefix" {
  type    = string
  default = "cloud-games"
}

# ---------- Optional ECS Notifications runtime ----------

variable "notifications_image_uri" {
  type    = string
  default = ""
}

variable "notifications_service_name" {
  type    = string
  default = "notifications"
}

variable "notifications_task_cpu" {
  type    = number
  default = 256
}

variable "notifications_task_memory" {
  type    = number
  default = 512
}

variable "notifications_desired_count" {
  type    = number
  default = 1
}

variable "notifications_log_retention_days" {
  type    = number
  default = 7
}

variable "ecs_lab_role_arn" {
  type        = string
  description = "Optional IAM role ARN used by ECS tasks. Leave empty to omit this role field."
  default     = ""
}

# ---------- EKS ----------

variable "eks_kubernetes_version" {
  type        = string
  description = "Kubernetes minor version for the managed control plane."
  default     = "1.30"
}

variable "eks_node_instance_types" {
  type        = list(string)
  description = "EC2 instance types for the main node group."
  default     = ["t3.medium"]
}

variable "eks_node_capacity_type" {
  type        = string
  description = "ON_DEMAND or SPOT"
  default     = "SPOT"
}

variable "eks_node_desired_size" {
  type    = number
  default = 2
}

variable "eks_node_min_size" {
  type    = number
  default = 1
}

variable "eks_node_max_size" {
  type    = number
  default = 3
}

# ---------- ElastiCache Redis ----------

variable "redis_node_type" {
  type    = string
  default = "cache.t4g.micro"
}

variable "redis_engine_version" {
  type    = string
  default = "7.1"
}

# ---------- OpenSearch ----------

variable "opensearch_engine_version" {
  type    = string
  default = "OpenSearch_2.11"
}

variable "opensearch_instance_type" {
  type    = string
  default = "t3.small.search"
}

variable "opensearch_instance_count" {
  type    = number
  default = 1
}

variable "opensearch_volume_size_gb" {
  type    = number
  default = 10
}

variable "opensearch_master_username" {
  type      = string
  default   = "admin"
  sensitive = true
}

variable "opensearch_master_password" {
  type        = string
  description = "Master password for OpenSearch fine-grained access. MUST be >= 8 chars with mixed case + digit + symbol."
  sensitive   = true

}

# ---------- DynamoDB ----------

variable "dynamodb_audit_table_name" {
  type    = string
  default = "cloud-games-audit-events"
}

# ---------- Secrets Manager bundled secret ----------

variable "jwt_secret" {
  type        = string
  description = "Symmetric secret used to sign JWTs. Should be rotated; pass via -var or tfvars in prod."
  sensitive   = true

}

variable "sql_connection_string" {
  type        = string
  description = "SQL Server connection string for users/catalog/payments databases."
  sensitive   = true

}

variable "rabbitmq_username" {
  type      = string
  sensitive = true
  default   = "fcg"
}

variable "rabbitmq_password" {
  type      = string
  sensitive = true

}
variable "payment_webhook_api_key" {
  type        = string
  description = "Webhook API key accepted by the payments service."
  sensitive   = true
}

variable "admin_user_name" {
  type    = string
  default = "Administrador"
}

variable "admin_user_email" {
  type    = string
  default = "adm@fcg.com"
}

variable "admin_user_password" {
  type        = string
  description = "Initial admin password for demo seeding."
  sensitive   = true
}

variable "admin_user_role" {
  type    = string
  default = "Administrator"
}

variable "admin_user_status" {
  type    = string
  default = "Active"
}

variable "admin_user_email_confirmed" {
  type    = string
  default = "true"
}

# ---------- Kubernetes (consumed by IRSA assume policies) ----------

variable "k8s_namespace_apps" {
  type        = string
  description = "Kubernetes namespace where application service accounts live."
  default     = "fcg-apps"
}

