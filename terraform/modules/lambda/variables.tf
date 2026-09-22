variable "artifact_bucket_id" {
  type        = string
  description = "The ID of the S3 bucket for Lambda artifacts"
}

variable "raw_events_bucket_id" {
  type        = string
  description = "The name of the S3 bucket for raw events"
}


variable "ingestion_role_arn" {
  type        = string
  description = "ARN of the ingestion Lambda execution role"
}

variable "processor_role_arn" {
  type        = string
  description = "ARN of the processor Lambda execution role"
}

variable "query_role_arn" {
  type        = string
  description = "ARN of the query Lambda execution role"
}


variable "pydantic_layer_arn" {
  type        = string
  description = "ARN of the Pydantic Lambda layer"
}

variable "common_layer_arn" {
  type        = string
  description = "ARN of the Common Lambda layer"
}



variable "events_queue_arn" {
  type        = string
  description = "ARN of the events SQS queue"
}

variable "events_queue_url" {
  type        = string
  description = "URL of the events SQS queue"
}



variable "dynamodb_table_name" {
  type        = string
  description = "The name of the DynamoDB table for processed events"
}
