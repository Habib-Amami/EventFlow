output "dynamodb_table_name" {
  description = "Name of the processed events table"
  value       = aws_dynamodb_table.results.name
}

output "dynamodb_table_arn" {
  description = "ARN of the processed events table"
  value       = aws_dynamodb_table.results.arn
}
