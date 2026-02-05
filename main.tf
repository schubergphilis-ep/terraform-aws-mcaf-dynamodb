locals {
  attribute_names     = toset([for a in var.attributes : a.name])
  attribute_name_list = [for a in var.attributes : a.name]

  table_key_names = toset(compact([var.hash_key, var.range_key]))

  gsi_key_names = toset(flatten([
    for g in var.global_secondary_indexes :
    compact([g.hash_key, try(g.range_key, null)])
  ]))

  lsi_key_names = toset([
    for l in var.local_secondary_indexes : l.range_key
  ])

  all_key_names = setunion(local.table_key_names, local.gsi_key_names, local.lsi_key_names)

  missing_key_attributes = setsubtract(local.all_key_names, local.attribute_names)
}




resource "aws_dynamodb_table" "table" {
  name                        = var.name
  billing_mode                = var.billing_mode
  deletion_protection_enabled = var.deletion_protection_enabled

  hash_key  = var.hash_key
  range_key = var.range_key

  # Only required when billing_mode == PROVISIONED
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_view_type

  table_class = var.table_class

  point_in_time_recovery {
    enabled                 = var.point_in_time_recovery_enabled
    recovery_period_in_days = var.point_in_time_recovery_enabled ? var.point_in_time_recovery_period_in_days : null
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      enabled        = true
      attribute_name = var.ttl_attribute_name
    }
  }

  dynamic "on_demand_throughput" {
    for_each = var.table_on_demand_throughput != null ? [var.table_on_demand_throughput] : []

    content {
      max_read_request_units  = on_demand_throughput.value.max_read_request_units
      max_write_request_units = on_demand_throughput.value.max_write_request_units
    }
  }

  dynamic "warm_throughput" {
    for_each = var.table_warm_throughput != null ? [var.table_warm_throughput] : []

    content {
      read_units_per_second  = warm_throughput.value.read_units_per_second
      write_units_per_second = warm_throughput.value.write_units_per_second
    }
  }

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", null)
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      projection_type    = global_secondary_index.value.projection_type
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      read_capacity      = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "read_capacity", null) : null
      write_capacity     = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "write_capacity", null) : null

      dynamic "on_demand_throughput" {
        for_each = lookup(global_secondary_index.value, "on_demand_throughput", null) != null ? [global_secondary_index.value.on_demand_throughput] : []

        content {
          max_read_request_units  = on_demand_throughput.value.max_read_request_units
          max_write_request_units = on_demand_throughput.value.max_write_request_units
        }
      }

      dynamic "warm_throughput" {
        for_each = lookup(global_secondary_index.value, "warm_throughput", null) != null ? [global_secondary_index.value.warm_throughput] : []

        content {
          read_units_per_second  = warm_throughput.value.read_units_per_second
          write_units_per_second = warm_throughput.value.write_units_per_second
        }
      }
    }
  }

  dynamic "replica" {
    for_each = var.replica_regions
    content {
      region_name                 = replica.value.region_name
      kms_key_arn                 = lookup(replica.value, "kms_key_arn", null)
      propagate_tags              = lookup(replica.value, "propagate_tags", null)
      point_in_time_recovery      = lookup(replica.value, "point_in_time_recovery", null)
      consistency_mode            = lookup(replica.value, "consistency_mode", null)
      deletion_protection_enabled = lookup(replica.value, "deletion_protection_enabled", null)
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )

  # DynamoDB operations can be slow when PITR/replicas/indexes are involved.
  # These timeouts reduce flaky CI applies (especially on first create).
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  lifecycle {
    # Fast, readable errors for common misconfigurations.
    precondition {
      condition     = !var.ttl_enabled || (var.ttl_attribute_name != null && var.ttl_attribute_name != "")
      error_message = "ttl_attribute_name must be set when ttl_enabled is true."
    }

    precondition {
      condition     = !var.stream_enabled || (var.stream_view_type != null && var.stream_view_type != "")
      error_message = "stream_view_type must be set when stream_enabled is true."
    }

    precondition {
      condition = (
        var.billing_mode != "PROVISIONED"
        || (var.read_capacity != null && var.write_capacity != null)
      )
      error_message = "read_capacity and write_capacity must be set when billing_mode is PROVISIONED."
    }

    precondition {
      condition     = length(local.missing_key_attributes) == 0
      error_message = "Missing attribute definitions for keys/indexes: ${join(", ", tolist(local.missing_key_attributes))}. Add them to var.attributes."
    }

    precondition {
      condition     = length(local.attribute_name_list) == length(toset(local.attribute_name_list))
      error_message = "Duplicate attribute names found in var.attributes."
    }

    precondition {
      condition = (
        length(var.replica_regions) == 0
        || (var.stream_enabled && var.stream_view_type == "NEW_AND_OLD_IMAGES")
      )
      error_message = "Global Tables (replica_regions) require stream_enabled = true and stream_view_type = 'NEW_AND_OLD_IMAGES'."
    }
  }
}

resource "aws_dynamodb_contributor_insights" "table_insight" {
  count = var.enable_dynamodb_insights ? 1 : 0

  # Reference the table resource to enforce correct creation order.
  table_name = aws_dynamodb_table.table.name

  # Explicit dependency for clarity and future-proofing (redundant with the reference above).
  depends_on = [aws_dynamodb_table.table]
}

resource "aws_dynamodb_contributor_insights" "gsi_insights" {
  for_each = var.enable_dynamodb_insights_gsis ? {
    for g in var.global_secondary_indexes : g.name => g
  } : {}

  table_name = aws_dynamodb_table.table.name
  index_name = each.key
}
