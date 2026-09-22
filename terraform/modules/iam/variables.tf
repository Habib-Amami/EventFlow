variable "events_queue_arn" {
  type        = string
  description = "The ARN of the SQS queue for events"
}

variable "raw_events_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket for raw events"
}

variable "dynamodb_table_arn" {
  type        = string
  description = "The ARN of the DynamoDB table for processed events"
}
