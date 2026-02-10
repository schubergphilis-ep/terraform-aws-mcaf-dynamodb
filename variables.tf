############################################
# Table identity & keys
############################################

variable "name" {
  type        = string
  description = "DynamoDB table name."
}

variable "hash_key" {
  type        = string
  description = "Partition (hash) key attribute name. Must be defined in `attributes`."
}

variable "range_key" {
  type        = string
  default     = null
  description = "Sort (range) key attribute name (optional). Must be defined in `attributes` when set."
}

variable "attributes" {
  type = list(object({
    name = string
    type = string
  }))

  description = <<-EOT
  Attribute definitions for table keys and index keys (provider constraint: only key/index attributes may be declared).
  Each item must include: `name` and `type` (S, N, or B).

  Note: TTL attribute must NOT be declared here unless it is used as a key in an index.
  EOT

  validation {
    condition     = alltrue([for a in var.attributes : contains(["S", "N", "B"], a.type)])
    error_message = "attributes[*].type must be one of: S, N, B."
  }
}

############################################
# Billing & throughput
############################################

variable "billing_mode" {
  type        = string
  default     = "PAY_PER_REQUEST"
  description = "Billing mode: PROVISIONED or PAY_PER_REQUEST."

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "billing_mode must be PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "read_capacity" {
  type        = number
  default     = null
  description = "Read capacity units (RCU) when billing_mode is PROVISIONED."
}

variable "write_capacity" {
  type        = number
  default     = null
  description = "Write capacity units (WCU) when billing_mode is PROVISIONED."
}

variable "table_class" {
  type        = string
  default     = "STANDARD"
  description = "Table class: STANDARD or STANDARD_INFREQUENT_ACCESS."

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "table_class must be STANDARD or STANDARD_INFREQUENT_ACCESS."
  }
}

variable "table_on_demand_throughput" {
  type = object({
    max_read_request_units  = optional(number, null)
    max_write_request_units = optional(number, null)
  })
  default     = null
  description = "Optional caps for on-demand mode. Set -1 to remove the cap (module/provider semantics dependent)."
}

variable "table_warm_throughput" {
  type = object({
    read_units_per_second  = optional(number, null)
    write_units_per_second = optional(number, null)
  })
  default     = null
  description = "Optional warm throughput settings (if supported)."
}

############################################
# Indexes
############################################

variable "local_secondary_indexes" {
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string), null)
  }))
  default     = []
  description = "Local secondary indexes (LSIs). Only settable at table creation time."
}

variable "global_secondary_indexes" {
  type = list(object({
    name            = string
    hash_key        = string
    projection_type = string
    range_key       = optional(string, null)

    read_capacity  = optional(number, null)
    write_capacity = optional(number, null)

    non_key_attributes = optional(list(string), null)

    on_demand_throughput = optional(object({
      max_read_request_units  = optional(number, null)
      max_write_request_units = optional(number, null)
    }), null)

    warm_throughput = optional(object({
      read_units_per_second  = optional(number, null)
      write_units_per_second = optional(number, null)
    }), null)
  }))
  default     = []
  description = "Global secondary indexes (GSIs)."
}

############################################
# Streams
############################################

variable "stream_enabled" {
  type        = bool
  default     = false
  description = "Enable DynamoDB Streams."
}

variable "stream_view_type" {
  type        = string
  default     = null
  description = "Stream view type when streams are enabled: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."

  validation {
    condition = (
      var.stream_view_type == null ||
      contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    )
    error_message = "stream_view_type must be one of: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  }
}

############################################
# TTL
############################################

variable "ttl_enabled" {
  type        = bool
  default     = false
  description = "Enable Time To Live (TTL)."
}

variable "ttl_attribute_name" {
  type        = string
  default     = "ttl"
  description = "TTL attribute name (Unix epoch time in seconds). Used only when ttl_enabled is true."
}

############################################
# Replication (Global Tables)
############################################

variable "replica_regions" {
  type = list(object({
    region_name                 = string
    kms_key_arn                 = optional(string, null)
    propagate_tags              = optional(bool, null)
    point_in_time_recovery      = optional(bool, null)
    consistency_mode            = optional(string, null)
    deletion_protection_enabled = optional(bool, null)
  }))
  default     = []
  description = "Replica regions configuration for global tables."

  validation {
    condition = alltrue([
      for r in var.replica_regions :
      r.consistency_mode == null || contains(["STRONG", "EVENTUAL"], r.consistency_mode)
    ])
    error_message = "replica_regions[*].consistency_mode must be STRONG or EVENTUAL when set."
  }
}

############################################
# Durability & protection
############################################

variable "point_in_time_recovery_enabled" {
  type        = bool
  default     = true
  description = "Enable point-in-time recovery (PITR)."
}

variable "point_in_time_recovery_period_in_days" {
  type        = number
  default     = 35
  description = "PITR recovery period in days (1..35)."

  validation {
    condition     = var.point_in_time_recovery_period_in_days >= 1 && var.point_in_time_recovery_period_in_days <= 35
    error_message = "point_in_time_recovery_period_in_days must be between 1 and 35."
  }
}

variable "deletion_protection_enabled" {
  type        = bool
  default     = true
  description = "Enable deletion protection."
}

############################################
# Observability
############################################

variable "enable_dynamodb_insights" {
  type        = bool
  default     = false
  description = "Enable DynamoDB Contributor Insights."
}

variable "enable_dynamodb_insights_gsis" {
  type        = bool
  default     = false
  description = "Enable Contributor Insights on all GSIs."
}

############################################
# Encryption & tags
############################################

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN for server-side encryption. When null, AWS-managed key (aws/dynamodb) is used."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources."
}
