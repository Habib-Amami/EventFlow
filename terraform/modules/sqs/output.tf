output "event_queue_arn" {
  description = "ARN of the events queue"
  value       = aws_sqs_queue.event_queue.arn
}

output "event_queue_url" {
  description = "URL of the events queue"
  value       = aws_sqs_queue.event_queue.url
}