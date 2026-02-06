# terraform-aws-mcaf-dynamodb

Terraform module to create an AWS DynamoDB Table.

IMPORTANT: We do not pin modules to versions in our examples. We highly recommend that in your code you pin the version to the exact version you are using so that your infrastructure remains stable.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.13.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_contributor_insights.gsi_insights](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_contributor_insights) | resource |
| [aws_dynamodb_contributor_insights.table_insight](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_contributor_insights) | resource |
| [aws_dynamodb_table.ondemand](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_dynamodb_table.provisioned_autoscaled_table_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_dynamodb_table.provisioned_autoscaled_with_gsis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_dynamodb_table.provisioned_static](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Attribute definitions for table keys and index keys (provider constraint: only key/index attributes may be declared).<br/>Each item must include: `name` and `type` (S, N, or B).<br/><br/>Note: TTL attribute must NOT be declared here unless it is used as a key in an index. | <pre>list(object({<br/>    name = string<br/>    type = string<br/>  }))</pre> | n/a | yes |
| <a name="input_autoscaling_ignores_gsis"></a> [autoscaling\_ignores\_gsis](#input\_autoscaling\_ignores\_gsis) | When enable\_autoscaling=true, if this is true then the module ignores the entire global\_secondary\_index block to prevent<br/>capacity thrash when GSIs are autoscaled externally. Trade-off: Terraform will not detect drift for GSI schema settings<br/>(projection\_type, keys, non\_key\_attributes, etc.) while enabled. | `bool` | `true` | no |
| <a name="input_billing_mode"></a> [billing\_mode](#input\_billing\_mode) | Billing mode: PROVISIONED or PAY\_PER\_REQUEST. | `string` | `"PAY_PER_REQUEST"` | no |
| <a name="input_deletion_protection_enabled"></a> [deletion\_protection\_enabled](#input\_deletion\_protection\_enabled) | Enable deletion protection. | `bool` | `true` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | If true and billing\_mode=PROVISIONED, ignores changes to RCU/WCU to allow external Auto Scaling to manage them. | `bool` | `false` | no |
| <a name="input_enable_dynamodb_insights"></a> [enable\_dynamodb\_insights](#input\_enable\_dynamodb\_insights) | Enable DynamoDB Contributor Insights. | `bool` | `false` | no |
| <a name="input_enable_dynamodb_insights_gsis"></a> [enable\_dynamodb\_insights\_gsis](#input\_enable\_dynamodb\_insights\_gsis) | Enable Contributor Insights on all GSIs. | `bool` | `false` | no |
| <a name="input_global_secondary_indexes"></a> [global\_secondary\_indexes](#input\_global\_secondary\_indexes) | Global secondary indexes (GSIs). | <pre>list(object({<br/>    name            = string<br/>    hash_key        = string<br/>    projection_type = string<br/>    range_key       = optional(string, null)<br/><br/>    read_capacity  = optional(number, null)<br/>    write_capacity = optional(number, null)<br/><br/>    non_key_attributes = optional(list(string), null)<br/><br/>    on_demand_throughput = optional(object({<br/>      max_read_request_units  = optional(number, null)<br/>      max_write_request_units = optional(number, null)<br/>    }), null)<br/><br/>    warm_throughput = optional(object({<br/>      read_units_per_second  = optional(number, null)<br/>      write_units_per_second = optional(number, null)<br/>    }), null)<br/>  }))</pre> | `[]` | no |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | Partition (hash) key attribute name. Must be defined in `attributes`. | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key ARN for server-side encryption. When null, AWS-managed key (aws/dynamodb) is used. | `string` | `null` | no |
| <a name="input_local_secondary_indexes"></a> [local\_secondary\_indexes](#input\_local\_secondary\_indexes) | Local secondary indexes (LSIs). Only settable at table creation time. | <pre>list(object({<br/>    name               = string<br/>    range_key          = string<br/>    projection_type    = string<br/>    non_key_attributes = optional(list(string), null)<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | DynamoDB table name. | `string` | n/a | yes |
| <a name="input_point_in_time_recovery_enabled"></a> [point\_in\_time\_recovery\_enabled](#input\_point\_in\_time\_recovery\_enabled) | Enable point-in-time recovery (PITR). | `bool` | `true` | no |
| <a name="input_point_in_time_recovery_period_in_days"></a> [point\_in\_time\_recovery\_period\_in\_days](#input\_point\_in\_time\_recovery\_period\_in\_days) | PITR recovery period in days (1..35). | `number` | `35` | no |
| <a name="input_range_key"></a> [range\_key](#input\_range\_key) | Sort (range) key attribute name (optional). Must be defined in `attributes` when set. | `string` | `null` | no |
| <a name="input_read_capacity"></a> [read\_capacity](#input\_read\_capacity) | Read capacity units (RCU) when billing\_mode is PROVISIONED. | `number` | `null` | no |
| <a name="input_replica_regions"></a> [replica\_regions](#input\_replica\_regions) | Replica regions configuration for global tables. | <pre>list(object({<br/>    region_name                 = string<br/>    kms_key_arn                 = optional(string, null)<br/>    propagate_tags              = optional(bool, null)<br/>    point_in_time_recovery      = optional(bool, null)<br/>    consistency_mode            = optional(string, null)<br/>    deletion_protection_enabled = optional(bool, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_stream_enabled"></a> [stream\_enabled](#input\_stream\_enabled) | Enable DynamoDB Streams. | `bool` | `false` | no |
| <a name="input_stream_view_type"></a> [stream\_view\_type](#input\_stream\_view\_type) | Stream view type when streams are enabled: KEYS\_ONLY, NEW\_IMAGE, OLD\_IMAGE, NEW\_AND\_OLD\_IMAGES. | `string` | `null` | no |
| <a name="input_table_class"></a> [table\_class](#input\_table\_class) | Table class: STANDARD or STANDARD\_INFREQUENT\_ACCESS. | `string` | `"STANDARD"` | no |
| <a name="input_table_on_demand_throughput"></a> [table\_on\_demand\_throughput](#input\_table\_on\_demand\_throughput) | Optional caps for on-demand mode. Set -1 to remove the cap (module/provider semantics dependent). | <pre>object({<br/>    max_read_request_units  = optional(number, null)<br/>    max_write_request_units = optional(number, null)<br/>  })</pre> | `null` | no |
| <a name="input_table_warm_throughput"></a> [table\_warm\_throughput](#input\_table\_warm\_throughput) | Optional warm throughput settings (if supported). | <pre>object({<br/>    read_units_per_second  = optional(number, null)<br/>    write_units_per_second = optional(number, null)<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources. | `map(string)` | `{}` | no |
| <a name="input_ttl_attribute_name"></a> [ttl\_attribute\_name](#input\_ttl\_attribute\_name) | TTL attribute name (Unix epoch time in seconds). Used only when ttl\_enabled is true. | `string` | `"ttl"` | no |
| <a name="input_ttl_enabled"></a> [ttl\_enabled](#input\_ttl\_enabled) | Enable Time To Live (TTL). | `bool` | `false` | no |
| <a name="input_write_capacity"></a> [write\_capacity](#input\_write\_capacity) | Write capacity units (WCU) when billing\_mode is PROVISIONED. | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the DynamoDB table. |
| <a name="output_gsi_names"></a> [gsi\_names](#output\_gsi\_names) | List of GSI names. |
| <a name="output_id"></a> [id](#output\_id) | ID of the DynamoDB table. |
| <a name="output_name"></a> [name](#output\_name) | Name of the DynamoDB table. |
| <a name="output_stream_arn"></a> [stream\_arn](#output\_stream\_arn) | ARN of the DynamoDB table stream (empty if streams are disabled). |
| <a name="output_stream_label"></a> [stream\_label](#output\_stream\_label) | Timestamp label of the DynamoDB table stream (empty if streams are disabled). |
<!-- END_TF_DOCS -->

## Licensing

100% Open Source and licensed under the Apache License Version 2.0. See [LICENSE](https://github.com/schubergphilis/terraform-aws-mcaf-dynamodb/blob/master/LICENSE) for full details.
