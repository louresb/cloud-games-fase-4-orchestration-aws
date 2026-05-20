# Append-only audit log. Single-table design, PAY_PER_REQUEST so we don't pay idle capacity.
#   PK: TenantId         (HASH)   → FIAP / Alura / PM3 / unknown
#   SK: SortKey          (RANGE)  → "<ISO timestamp>#<id>" (newest-first when ScanIndexForward=false)
#   GSI1 (gsi_correlation): CorrelationId / SortKey   → trace a request across services
#   GSI2 (gsi_event_type):  EventType     / SortKey   → filter by event type

resource "aws_dynamodb_table" "audit_events" {
  name         = var.dynamodb_audit_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "TenantId"
  range_key    = "SortKey"

  attribute {
    name = "TenantId"
    type = "S"
  }

  attribute {
    name = "SortKey"
    type = "S"
  }

  attribute {
    name = "CorrelationId"
    type = "S"
  }

  attribute {
    name = "EventType"
    type = "S"
  }

  global_secondary_index {
    name            = "gsi_correlation"
    hash_key        = "CorrelationId"
    range_key       = "SortKey"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "gsi_event_type"
    hash_key        = "EventType"
    range_key       = "SortKey"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(local.common_tags, { Service = "audit" })
}
