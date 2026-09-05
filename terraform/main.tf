# Composition root. Resource definitions live in dedicated files:
#   - ecr.tf            ECR repositories (5 services)
#   - eks.tf            EKS cluster + managed node group
#   - elasticache.tf    ElastiCache Redis (catalog cache)
#   - opensearch.tf     OpenSearch Service (catalog search)
#   - dynamodb.tf       Audit events table
#   - secrets-manager.tf  Secret values consumed by ExternalSecrets in K8s
#   - iam-irsa.tf       IRSA roles per service (pod-level IAM)
#   - ecs-notifications.tf  Optional ECS Fargate runtime for Notifications

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Phase       = "4"
  }
}

# Default VPC + subnets are reused to keep the demo footprint small.
# Production should provision a dedicated VPC with public/private subnets and a NAT gateway.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Main async queue shared by the optional SQS payment-notification flow.
resource "aws_sqs_queue" "payment_notification" {
  name = var.main_sqs_queue_name_prefix != "" ? "${var.main_sqs_queue_name_prefix}-${var.main_sqs_queue_name}" : var.main_sqs_queue_name
  tags = local.common_tags
}
