resource "aws_sqs_queue" "event_dlq" {
  name = "events-dlq"
}

resource "aws_sqs_queue" "event_queue" {
  name = "events-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.event_dlq.arn
    maxReceiveCount     = 3
  })
}
