# IRSA (IAM Roles for Service Accounts) — pod-level IAM without baking AWS creds into images.
#
# Two roles are created here:
#   1. fcg_audit  — DynamoDB read/write on the audit table + Secrets Manager read.
#   2. fcg_common — Secrets Manager read for the bundled fcg-secrets entry. Used by users/catalog/payments/notifications.

locals {
  oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn
  oidc_provider_url = replace(aws_iam_openid_connect_provider.eks.url, "https://", "")
}

# ---------- audit role ----------

data "aws_iam_policy_document" "audit_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${var.k8s_namespace_apps}:audit-sa"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "audit" {
  name               = "${local.name_prefix}-audit-irsa"
  assume_role_policy = data.aws_iam_policy_document.audit_assume_role.json
  tags               = merge(local.common_tags, { Service = "audit" })
}

data "aws_iam_policy_document" "audit_dynamodb" {
  statement {
    sid    = "DynamoAuditTable"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTable"
    ]
    resources = [
      aws_dynamodb_table.audit_events.arn,
      "${aws_dynamodb_table.audit_events.arn}/index/*"
    ]
  }

  statement {
    sid       = "SecretsRead"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [aws_secretsmanager_secret.fcg.arn]
  }
}

resource "aws_iam_role_policy" "audit" {
  name   = "audit-dynamodb-secrets"
  role   = aws_iam_role.audit.id
  policy = data.aws_iam_policy_document.audit_dynamodb.json
}

# ---------- common role (users/catalog/payments/notifications) ----------

# One IRSA role per service so each pod can only assume its own role.
# All services share the same Secrets Manager read policy via aws_iam_role_policy.common_secrets_read.

locals {
  common_services = ["users", "catalog", "payments", "notifications"]
}

data "aws_iam_policy_document" "common_assume_role" {
  for_each = toset(local.common_services)

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${var.k8s_namespace_apps}:${each.value}-sa"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "common" {
  for_each           = toset(local.common_services)
  name               = "${local.name_prefix}-${each.value}-irsa"
  assume_role_policy = data.aws_iam_policy_document.common_assume_role[each.value].json
  tags               = merge(local.common_tags, { Service = each.value })
}

data "aws_iam_policy_document" "common_secrets" {
  statement {
    sid       = "SecretsRead"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [aws_secretsmanager_secret.fcg.arn]
  }

  statement {
    sid    = "SqsForEventDriven"
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
    resources = [aws_sqs_queue.payment_notification.arn]
  }
}

resource "aws_iam_role_policy" "common_secrets" {
  for_each = aws_iam_role.common
  name     = "secrets-and-sqs"
  role     = each.value.id
  policy   = data.aws_iam_policy_document.common_secrets.json
}
