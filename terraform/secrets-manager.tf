# Secret values consumed by ExternalSecrets Operator running inside EKS.
# Replace values through terraform.tfvars, CI/CD variables, or aws secretsmanager put-secret-value.

locals {
  fcg_secret_payload = {
    Jwt__Secret                        = var.jwt_secret
    ConnectionStrings__DefaultConnection = var.sql_connection_string
    RabbitMq__UserName                 = var.rabbitmq_username
    RabbitMq__Password                 = var.rabbitmq_password
    PaymentSettings__WebhookApiKey     = var.payment_webhook_api_key
    AdminUser__Name                    = var.admin_user_name
    AdminUser__Email                   = var.admin_user_email
    AdminUser__Password                = var.admin_user_password
    AdminUser__Role                    = var.admin_user_role
    AdminUser__Status                  = var.admin_user_status
    AdminUser__EmailConfirmed          = var.admin_user_email_confirmed
    OpenSearch__Username               = var.opensearch_master_username
    OpenSearch__Password               = var.opensearch_master_password
    Redis__ConnectionString            = "${aws_elasticache_replication_group.redis.primary_endpoint_address}:${aws_elasticache_replication_group.redis.port}"
  }
}

resource "aws_secretsmanager_secret" "fcg" {
  name        = "${local.name_prefix}-fcg-secrets"
  description = "Bundled secrets for Fiap Cloud Games (consumed by ExternalSecrets in EKS)"
  tags        = local.common_tags
}

resource "aws_secretsmanager_secret_version" "fcg" {
  secret_id     = aws_secretsmanager_secret.fcg.id
  secret_string = jsonencode(local.fcg_secret_payload)
}
