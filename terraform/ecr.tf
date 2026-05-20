# Private container registry — one repo per microservice.
# Image scanning on push catches CVEs early; lifecycle keeps the last 10 images.

locals {
  ecr_repositories = {
    users         = var.ecr_users_repository_name
    payments      = var.ecr_payments_repository_name
    notifications = var.ecr_notifications_repository_name
    catalog       = var.ecr_catalog_repository_name
    audit         = var.ecr_audit_repository_name
  }
}

resource "aws_ecr_repository" "this" {
  for_each = local.ecr_repositories

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, { Service = each.key })
}

resource "aws_ecr_lifecycle_policy" "keep_last_10" {
  for_each   = aws_ecr_repository.this
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = { type = "expire" }
      }
    ]
  })
}
