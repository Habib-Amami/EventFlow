variable "ingestion_lambda_invoke_arn" {
  type = string
}

variable "ingestion_lambda_name" {
  description = "Name of the ingestion Lambda"
  type        = string
}

variable "query_lambda_invoke_arn" {
  type        = string
  description = "Invoke ARN of the query Lambda"
}

variable "query_lambda_name" {
  type        = string
  description = "Name of the query Lambda"
}
