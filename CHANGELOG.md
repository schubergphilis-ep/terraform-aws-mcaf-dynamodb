# Changelog

All notable changes to this project will automatically be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.3.0 - 2026-01-27

### What's Changed

On-Demand Throughput Support
Added table_on_demand_throughput variable to set maximum read/write request units for the table
Added on_demand_throughput field to global_secondary_indexes for per-GSI throughput caps
Enables cost control for tables using PAY_PER_REQUEST billing mode
Setting values to -1 removes the cap

Warm Throughput Support (AWS Provider >= 6.13.0)
Added table_warm_throughput variable for predictable performance provisioning
Added warm_throughput field to global_secondary_indexes for per-GSI warm throughput
Minimum values: read_units_per_second: 12000, write_units_per_second: 4000
Important for workloads requiring consistent baseline performance

Point-in-Time Recovery Period Configuration
Added point_in_time_recovery_period_in_days variable (1-35 days, default: 35)
Includes validation to ensure the value is within AWS's valid range
Backward compatible with existing point_in_time_recovery_enabled boolean
Provides granular control over backup retention

Replica Enhancements
Added consistency_mode field to replica_regions ("STRONG" or "EVENTUAL")
Added deletion_protection_enabled field to replica_regions for replica-level protection
Includes validation to ensure consistency_mode is a valid value
Enables better control over Global Table replica behavior

Contributor Insights Resource Fix
Fixed aws_dynamodb_contributor_insights to reference aws_dynamodb_table.table.name instead of var.name
Added explicit depends_on to ensure proper resource creation order
Prevents potential race conditions and follows Terraform best practices

Requires AWS Provider >= 6.13.0

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-dynamodb/compare/v0.2.0...v0.3.0

## v0.2.0 - 2024-04-10

### What's Changed

#### 🚀 Features

* feat: add option to enable table deletion protection (#6) @markvl-sbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-dynamodb/compare/v0.1.1...v0.2.0

## v0.1.1 - 2024-02-01

### What's Changed

#### 🐛 Bug Fixes

* bug: remove the default value for the `kms_key_arn` variable (#4) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-dynamodb/compare/v0.1.0...v0.1.1
