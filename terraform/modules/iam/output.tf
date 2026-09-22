output "ingestion_lambda_exec_role_arn" {
  description = "ARN of the ingestion Lambda execution role"
  value       = aws_iam_role.ingestion_lambda_role.arn
}

output "processor_lambda_exec_role_arn" {
  description = "ARN of the processor Lambda execution role"
  value       = aws_iam_role.processor_lambda_role.arn
}

output "query_lambda_exec_role_arn" {
  description = "ARN of the query Lambda execution role"
  value       = aws_iam_role.query_lambda_role.arn
}
