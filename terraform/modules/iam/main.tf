# IAM role for the ingestion lambda function
resource "aws_iam_role" "ingestion_lambda_role" {
  name = "ingestion-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ingestion_logs" {
  role       = aws_iam_role.ingestion_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "ingestion_sqs_send" {
  name = "ingestion-sqs-send"
  role = aws_iam_role.ingestion_lambda_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = var.events_queue_arn
      }
    ]
  })
}



# IAM role for the processor lambda function
resource "aws_iam_role" "processor_lambda_role" {
  name = "processor-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "processor_logs" {
  role       = aws_iam_role.processor_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "processor_sqs" {
  name = "processor-sqs"
  role = aws_iam_role.processor_lambda_role.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ConsumeEventsQueue"
        Effect = "Allow"

        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]

        Resource = var.events_queue_arn
      },
    ]
  })
}

resource "aws_iam_role_policy" "processor_s3" {
  name = "processor-s3"
  role = aws_iam_role.processor_lambda_role.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "WriteToRawEventsBucket"
        Effect = "Allow"

        Action = [
          "s3:PutObject",
        ]

      Resource = "${var.raw_events_bucket_arn}/*" },
    ]
  })
}

resource "aws_iam_role_policy" "processor_dynamodb" {
  name = "processor-dynamodb"
  role = aws_iam_role.processor_lambda_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "WriteResults"
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = var.dynamodb_table_arn
      },
    ]
  })
}

# IAM role for the query Lambda function
resource "aws_iam_role" "query_lambda_role" {
  name = "query-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "query_logs" {
  role       = aws_iam_role.query_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "query_dynamodb" {
  name = "query-dynamodb"
  role = aws_iam_role.query_lambda_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:GetItem"]
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}
