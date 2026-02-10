output "name" {
  description = "Name of the DynamoDB table."
  value       = aws_dynamodb_table.table.name
}

output "arn" {
  description = "ARN of the DynamoDB table."
  value       = aws_dynamodb_table.table.arn
}

output "id" {
  description = "ID of the DynamoDB table."
  value       = aws_dynamodb_table.table.id
}

output "stream_arn" {
  description = "ARN of the DynamoDB table stream (empty if streams are disabled)."
  value       = try(aws_dynamodb_table.table.stream_arn, "")
}

output "stream_label" {
  description = "Timestamp label of the DynamoDB table stream (empty if streams are disabled)."
  value       = try(aws_dynamodb_table.table.stream_label, "")
}

output "gsi_names" {
  value       = [for g in var.global_secondary_indexes : g.name]
  description = "List of GSI names."
}
