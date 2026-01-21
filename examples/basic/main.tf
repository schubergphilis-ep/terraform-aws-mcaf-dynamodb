provider "aws" {
  region = "eu-west-1"
}

module "table" {
  source = "../.."

  name                                  = "example-testmac"
  hash_key                              = "pk"
  kms_key_arn                           = null
  range_key                             = "sk"
  point_in_time_recovery_enabled        = true
  point_in_time_recovery_period_in_days = 30

  table_on_demand_throughput = {
    max_read_request_units  = 1000
    max_write_request_units = 500
  }

  table_warm_throughput = {
    read_units_per_second  = 12000
    write_units_per_second = 4000
  }

  replica_regions = [
    {
      region_name                 = "us-east-1"
      consistency_mode            = "EVENTUAL"
      deletion_protection_enabled = true
      point_in_time_recovery      = true
    }
  ]

  attributes = [
    {
      name = "pk"
      type = "S"
    },
    {
      name = "sk"
      type = "S"
    },
    {
      name = "one_field#two_field#three_field"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "one_field-two_field-three_field"
      hash_key        = "pk"
      range_key       = "one_field#two_field#three_field"
      projection_type = "ALL"
      on_demand_throughput = {
        max_read_request_units  = 800
        max_write_request_units = 400
      }
      warm_throughput = {
        read_units_per_second  = 12000
        write_units_per_second = 4000
      }
    }
  ]

}
