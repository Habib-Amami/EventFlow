output "ingestion_lambda_arn" {
  description = "ARN of the ingestion Lambda function"
  value       = aws_lambda_function.ingestion.arn
}

output "ingestion_lambda_name" {
  description = "Name of the ingestion Lambda"
  value       = aws_lambda_function.ingestion.function_name
}

output "processor_lambda_arn" {
  description = "ARN of the processor Lambda function"
  value       = aws_lambda_function.processor.arn
}

output "query_lambda_arn" {
  description = "ARN of the query Lambda function"
  value       = aws_lambda_function.query.arn
}

output "query_lambda_name" {
  description = "Name of the query Lambda"
  value       = aws_lambda_function.query.function_name
}

output "query_lambda_invoke_arn" {
  description = "Invoke ARN of the query Lambda"
  value       = aws_lambda_function.query.invoke_arn
}

output "ingestion_lambda_invoke_arn" {
  description = "Invoke ARN of the ingestion Lambda"
  value       = aws_lambda_function.ingestion.invoke_arn
}