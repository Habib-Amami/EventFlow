output "pydantic_layer_arn" {
  description = "ARN of the Pydantic Lambda layer"
  value       = aws_lambda_layer_version.pydantic.arn
}

output "common_layer_arn" {
  description = "ARN of the common EventFlow Lambda layer"
  value       = aws_lambda_layer_version.common.arn
}