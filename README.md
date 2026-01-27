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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.13.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_contributor_insights.table_insight](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_contributor_insights) | resource |
| [aws_dynamodb_table.table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | List of nested attribute definitions. Only required for hash\_key and range\_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data. | `list(map(string))` | n/a | yes |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | The attribute to use as the hash (partition) key. Must also be defined as an attribute | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The ARN of the KMS key to use; if set to `null` the `aws/dynamodb` AWS-managed key will be used | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the DynamoDB table | `string` | n/a | yes |
| <a name="input_billing_mode"></a> [billing\_mode](#input\_billing\_mode) | Controls how you are billed for read/write throughput and how you manage capacity. The valid values are PROVISIONED or PAY\_PER\_REQUEST. | `string` | `"PAY_PER_REQUEST"` | no |
| <a name="input_deletion_protection_enabled"></a> [deletion\_protection\_enabled](#input\_deletion\_protection\_enabled) | Enables deletion protection for the table. | `bool` | `true` | no |
| <a name="input_enable_dynamodb_insights"></a> [enable\_dynamodb\_insights](#input\_enable\_dynamodb\_insights) | Set to true to enable CloudWatch contributor insights for DynamoDB | `bool` | `false` | no |
| <a name="input_global_secondary_indexes"></a> [global\_secondary\_indexes](#input\_global\_secondary\_indexes) | Describe a GSI for the table; subject to the normal limits on the number of GSIs, projected attributes, etc. | <pre>list(object({<br/>    name               = string<br/>    hash_key           = string<br/>    projection_type    = string<br/>    range_key          = optional(string, null)<br/>    read_capacity      = optional(string, null)<br/>    write_capacity     = optional(string, null)<br/>    non_key_attributes = optional(list(string), null)<br/>    on_demand_throughput = optional(object({<br/>      max_read_request_units  = optional(number, null)<br/>      max_write_request_units = optional(number, null)<br/>    }), null)<br/>    warm_throughput = optional(object({<br/>      read_units_per_second  = optional(number, null)<br/>      write_units_per_second = optional(number, null)<br/>    }), null)<br/>  }))</pre> | `[]` | no |
| <a name="input_local_secondary_indexes"></a> [local\_secondary\_indexes](#input\_local\_secondary\_indexes) | Describe a LSI on the table; these can only be allocated at creation so you cannot change this definition after you have created the resource. | <pre>list(object({<br/>    name               = string<br/>    range_key          = string<br/>    projection_type    = string<br/>    non_key_attributes = optional(list(string), null)<br/>  }))</pre> | `[]` | no |
| <a name="input_point_in_time_recovery_enabled"></a> [point\_in\_time\_recovery\_enabled](#input\_point\_in\_time\_recovery\_enabled) | Set to true to enable point-in-time recovery | `bool` | `true` | no |
| <a name="input_point_in_time_recovery_period_in_days"></a> [point\_in\_time\_recovery\_period\_in\_days](#input\_point\_in\_time\_recovery\_period\_in\_days) | The recovery period in days for point-in-time recovery. Must be between 1 and 35. Default is 35. | `number` | `35` | no |
| <a name="input_range_key"></a> [range\_key](#input\_range\_key) | The attribute to use as the range (sort) key. Must also be defined as an attribute | `string` | `null` | no |
| <a name="input_read_capacity"></a> [read\_capacity](#input\_read\_capacity) | The number of read units for this table. If the billing\_mode is PROVISIONED, this field should be greater than 0 | `number` | `null` | no |
| <a name="input_replica_regions"></a> [replica\_regions](#input\_replica\_regions) | Region names for creating replicas for a global DynamoDB table including parameters. | <pre>list(object({<br/>    region_name                 = string<br/>    kms_key_arn                 = optional(string, null)<br/>    propagate_tags              = optional(bool, null)<br/>    point_in_time_recovery      = optional(bool, null)<br/>    consistency_mode            = optional(string, null)<br/>    deletion_protection_enabled = optional(bool, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_stream_enabled"></a> [stream\_enabled](#input\_stream\_enabled) | Set to true to enable streams | `bool` | `false` | no |
| <a name="input_stream_view_type"></a> [stream\_view\_type](#input\_stream\_view\_type) | When an item in the table is modified, StreamViewType determines what information is written to the table's stream. Valid values are KEYS\_ONLY, NEW\_IMAGE, OLD\_IMAGE, NEW\_AND\_OLD\_IMAGES. | `string` | `null` | no |
| <a name="input_table_class"></a> [table\_class](#input\_table\_class) | The storage class of the table. Valid values are STANDARD and STANDARD\_INFREQUENT\_ACCESS | `string` | `null` | no |
| <a name="input_table_on_demand_throughput"></a> [table\_on\_demand\_throughput](#input\_table\_on\_demand\_throughput) | Sets the maximum number of read and write units for when the table is in on-demand mode. Set to -1 to remove the cap. | <pre>object({<br/>    max_read_request_units  = optional(number, null)<br/>    max_write_request_units = optional(number, null)<br/>  })</pre> | `null` | no |
| <a name="input_table_warm_throughput"></a> [table\_warm\_throughput](#input\_table\_warm\_throughput) | Sets the warm throughput for the table. Minimum values are read\_units\_per\_second: 12000, write\_units\_per\_second: 4000. | <pre>object({<br/>    read_units_per_second  = optional(number, null)<br/>    write_units_per_second = optional(number, null)<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_ttl_attribute_name"></a> [ttl\_attribute\_name](#input\_ttl\_attribute\_name) | The name of the table attribute to store the TTL timestamp in | `string` | `""` | no |
| <a name="input_ttl_enabled"></a> [ttl\_enabled](#input\_ttl\_enabled) | Indicates whether ttl is enabled | `bool` | `false` | no |
| <a name="input_write_capacity"></a> [write\_capacity](#input\_write\_capacity) | The number of write units for this table. If the billing\_mode is PROVISIONED, this field should be greater than 0 | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the DynamoDB table |
| <a name="output_id"></a> [id](#output\_id) | ID of the DynamoDB table |
<!-- END_TF_DOCS -->

## Licensing

100% Open Source and licensed under the Apache License Version 2.0. See [LICENSE](https://github.com/schubergphilis/terraform-aws-mcaf-dynamodb/blob/master/LICENSE) for full details.
