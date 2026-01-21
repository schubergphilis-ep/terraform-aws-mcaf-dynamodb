variable "attributes" {
  description = "List of nested attribute definitions. Only required for hash_key and range_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data."
  type        = list(map(string))
}

variable "billing_mode" {
  description = "Controls how you are billed for read/write throughput and how you manage capacity. The valid values are PROVISIONED or PAY_PER_REQUEST."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "deletion_protection_enabled" {
  description = "Enables deletion protection for the table."
  type        = bool
  default     = true
}

variable "enable_dynamodb_insights" {
  description = "Set to true to enable CloudWatch contributor insights for DynamoDB"
  type        = bool
  default     = false
}

variable "global_secondary_indexes" {
  description = "Describe a GSI for the table; subject to the normal limits on the number of GSIs, projected attributes, etc."
  type = list(object({
    name               = string
    hash_key           = string
    projection_type    = string
    range_key          = optional(string, null)
    read_capacity      = optional(string, null)
    write_capacity     = optional(string, null)
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

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key. Must also be defined as an attribute"
  type        = string
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key to use; if set to `null` the `aws/dynamodb` AWS-managed key will be used"
  type        = string
}

variable "local_secondary_indexes" {
  description = "Describe a LSI on the table; these can only be allocated at creation so you cannot change this definition after you have created the resource."
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string), null)
  }))
  default = []
}

variable "name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "point_in_time_recovery_enabled" {
  description = "Set to true to enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "point_in_time_recovery_period_in_days" {
  description = "The recovery period in days for point-in-time recovery. Must be between 1 and 35. Default is 35."
  type        = number
  default     = 35

  validation {
    condition     = var.point_in_time_recovery_period_in_days >= 1 && var.point_in_time_recovery_period_in_days <= 35
    error_message = "The point_in_time_recovery_period_in_days must be between 1 and 35 days."
  }
}


variable "range_key" {
  description = "The attribute to use as the range (sort) key. Must also be defined as an attribute"
  type        = string
  default     = null
}

variable "read_capacity" {
  description = "The number of read units for this table. If the billing_mode is PROVISIONED, this field should be greater than 0"
  type        = number
  default     = null
}

variable "replica_regions" {
  description = "Region names for creating replicas for a global DynamoDB table including parameters."
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
      for replica in var.replica_regions :
      replica.consistency_mode == null ||
      contains(["STRONG", "EVENTUAL"], replica.consistency_mode)
    ])
    error_message = "consistency_mode must be either 'STRONG' or 'EVENTUAL'."
  }
}

variable "stream_enabled" {
  description = "Set to true to enable streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "When an item in the table is modified, StreamViewType determines what information is written to the table's stream. Valid values are KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "table_class" {
  description = "The storage class of the table. Valid values are STANDARD and STANDARD_INFREQUENT_ACCESS"
  type        = string
  default     = null
}

variable "table_on_demand_throughput" {
  description = "Sets the maximum number of read and write units for when the table is in on-demand mode. Set to -1 to remove the cap."
  type = object({
    max_read_request_units  = optional(number, null)
    max_write_request_units = optional(number, null)
  })
  default = null
}

variable "table_warm_throughput" {
  description = "Sets the warm throughput for the table. Minimum values are read_units_per_second: 12000, write_units_per_second: 4000."
  type = object({
    read_units_per_second  = optional(number, null)
    write_units_per_second = optional(number, null)
  })
  default = null
}

variable "ttl_attribute_name" {
  description = "The name of the table attribute to store the TTL timestamp in"
  type        = string
  default     = ""
}

variable "ttl_enabled" {
  description = "Indicates whether ttl is enabled"
  type        = bool
  default     = false
}

variable "write_capacity" {
  description = "The number of write units for this table. If the billing_mode is PROVISIONED, this field should be greater than 0"
  type        = number
  default     = null
}
