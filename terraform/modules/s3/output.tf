output "lambda_artifacts_bucket_id" {
  value       = aws_s3_bucket.lambda_artifacts.id
  description = "The ID of the S3 bucket for Lambda artifacts"
}

output "raw_events_bucket_arn" {
  value       = aws_s3_bucket.raw_events.arn
  description = "The ARN of the S3 bucket for raw events"
}

output "raw_events_bucket_id" {
  value       = aws_s3_bucket.raw_events.id
  description = "The name of the S3 bucket for raw events"
}