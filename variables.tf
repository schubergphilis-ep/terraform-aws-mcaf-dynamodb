############################################
# Table identity & keys
############################################

variable "name" {
  description = "DynamoDB table name."
  type        = string
}

variable "hash_key" {
  description = "Partition (hash) key attribute name. Must be defined in `attributes`."
  type        = string
}

variable "range_key" {
  description = "Sort (range) key attribute name (optional). Must be defined in `attributes` when set."
  type        = string
  default     = null
}

variable "attributes" {
  description = <<-EOT
  Attribute definitions for table keys and index keys (provider constraint: only key/index attributes may be declared).
  Each item must include: `name` and `type` (S, N, or B).

  Note: TTL attribute must NOT be declared here unless it is used as a key in an index.
  EOT
  type = list(object({
    name = string
    type = string
  }))

  validation {
    condition     = alltrue([for a in var.attributes : contains(["S", "N", "B"], a.type)])
    error_message = "attributes[*].type must be one of: S, N, B."
  }
}

############################################
# Billing & throughput
############################################

variable "billing_mode" {
  description = "Billing mode: PROVISIONED or PAY_PER_REQUEST."
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "billing_mode must be PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "read_capacity" {
  description = "Read capacity units (RCU) when billing_mode is PROVISIONED."
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "Write capacity units (WCU) when billing_mode is PROVISIONED."
  type        = number
  default     = null
}

variable "table_class" {
  description = "Table class: STANDARD or STANDARD_INFREQUENT_ACCESS."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "table_class must be STANDARD or STANDARD_INFREQUENT_ACCESS."
  }
}

variable "table_on_demand_throughput" {
  description = "Optional caps for on-demand mode. Set -1 to remove the cap (module/provider semantics dependent)."
  type = object({
    max_read_request_units  = optional(number, null)
    max_write_request_units = optional(number, null)
  })
  default = null
}

variable "table_warm_throughput" {
  description = "Optional warm throughput settings (if supported)."
  type = object({
    read_units_per_second  = optional(number, null)
    write_units_per_second = optional(number, null)
  })
  default = null
}

############################################
# Indexes
############################################

variable "local_secondary_indexes" {
  description = "Local secondary indexes (LSIs). Only settable at table creation time."
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string), null)
  }))
  default = []
}

variable "global_secondary_indexes" {
  description = "Global secondary indexes (GSIs)."
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
  default = []
}

############################################
# Streams
############################################

variable "stream_enabled" {
  description = "Enable DynamoDB Streams."
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type when streams are enabled: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  type        = string
  default     = null

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
  description = "Enable Time To Live (TTL)."
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "TTL attribute name (Unix epoch time in seconds). Used only when ttl_enabled is true."
  type        = string
  default     = "ttl"
}

############################################
# Replication (Global Tables)
############################################

variable "replica_regions" {
  description = "Replica regions configuration for global tables."
  type = list(object({
    region_name                 = string
    kms_key_arn                 = optional(string, null)
    propagate_tags              = optional(bool, null)
    point_in_time_recovery      = optional(bool, null)
    consistency_mode            = optional(string, null)
    deletion_protection_enabled = optional(bool, null)
  }))
  default = []

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
  description = "Enable point-in-time recovery (PITR)."
  type        = bool
  default     = true
}

variable "point_in_time_recovery_period_in_days" {
  description = "PITR recovery period in days (1..35)."
  type        = number
  default     = 35

  validation {
    condition     = var.point_in_time_recovery_period_in_days >= 1 && var.point_in_time_recovery_period_in_days <= 35
    error_message = "point_in_time_recovery_period_in_days must be between 1 and 35."
  }
}

variable "deletion_protection_enabled" {
  description = "Enable deletion protection."
  type        = bool
  default     = true
}

############################################
# Observability
############################################

variable "enable_dynamodb_insights" {
  description = "Enable DynamoDB Contributor Insights."
  type        = bool
  default     = false
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
  description = "KMS key ARN for server-side encryption. When null, AWS-managed key (aws/dynamodb) is used."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
