data "archive_file" "ingestion_zip" {
  type = "zip"

  source_dir  = "${path.root}/../services/ingestion"
  output_path = "${path.root}/../build/ingestion.zip"
}

resource "aws_s3_object" "ingestion_code" {
  bucket = var.artifact_bucket_id

  key    = "ingestion/${data.archive_file.ingestion_zip.output_sha256}.zip"
  source = data.archive_file.ingestion_zip.output_path

  etag = data.archive_file.ingestion_zip.output_md5
}

resource "aws_lambda_function" "ingestion" {
  function_name = "ingestion"

  s3_bucket = var.artifact_bucket_id
  s3_key    = aws_s3_object.ingestion_code.key

  handler = "handler.lambda_handler"
  runtime = "python3.14"

  role = var.ingestion_role_arn

  layers = [
    var.pydantic_layer_arn,
    var.common_layer_arn
  ]

  environment {
    variables = {
      QUEUE_URL = var.events_queue_url
    }
  }
}

#########################################################
# Processor Lambda function
data "archive_file" "processor_zip" {
  type = "zip"

  source_dir  = "${path.root}/../services/processor"
  output_path = "${path.root}/../build/processor.zip"
}

resource "aws_s3_object" "processor_code" {
  bucket = var.artifact_bucket_id

  key    = "processor/${data.archive_file.processor_zip.output_sha256}.zip"
  source = data.archive_file.processor_zip.output_path

  etag = data.archive_file.processor_zip.output_md5
}

resource "aws_lambda_function" "processor" {
  depends_on = [
    aws_s3_object.processor_code
  ]

  function_name = "processor"

  s3_bucket = var.artifact_bucket_id
  s3_key    = aws_s3_object.processor_code.key

  handler = "handler.lambda_handler"
  runtime = "python3.14"

  role = var.processor_role_arn
  layers = [
    var.pydantic_layer_arn,
    var.common_layer_arn
  ]

  environment {
    variables = {
      RAW_EVENTS_BUCKET   = var.raw_events_bucket_id
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
    }
  }
}

resource "aws_lambda_event_source_mapping" "processor" {
  event_source_arn        = var.events_queue_arn
  function_name           = aws_lambda_function.processor.arn
  batch_size              = 10
  enabled                 = true
  function_response_types = ["ReportBatchItemFailures"]
}

data "archive_file" "query_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../services/query"
  output_path = "${path.root}/../build/query.zip"
}

resource "aws_s3_object" "query_code" {
  bucket = var.artifact_bucket_id
  key    = "query/${data.archive_file.query_zip.output_sha256}.zip"
  source = data.archive_file.query_zip.output_path
  etag   = data.archive_file.query_zip.output_md5
}

resource "aws_lambda_function" "query" {
  depends_on = [aws_s3_object.query_code]

  function_name = "query"
  s3_bucket     = var.artifact_bucket_id
  s3_key        = aws_s3_object.query_code.key
  handler       = "handler.lambda_handler"
  runtime       = "python3.14"
  role          = var.query_role_arn

  layers = [
    var.pydantic_layer_arn,
    var.common_layer_arn,
  ]

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
    }
  }
}
