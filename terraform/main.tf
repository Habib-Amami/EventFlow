module "sqs" {
  source = "./modules/sqs"
}

module "s3" {
  source = "./modules/s3"

  name_prefix = "eventflow-dev"
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "iam" {
  source = "./modules/iam"

  events_queue_arn      = module.sqs.event_queue_arn
  raw_events_bucket_arn = module.s3.raw_events_bucket_arn
  dynamodb_table_arn    = module.dynamodb.dynamodb_table_arn
}

module "lambda_layer" {
  source = "./modules/lambda-layer"
}

module "lambda" {
  source = "./modules/lambda"

  artifact_bucket_id   = module.s3.lambda_artifacts_bucket_id
  raw_events_bucket_id = module.s3.raw_events_bucket_id

  ingestion_role_arn = module.iam.ingestion_lambda_exec_role_arn
  processor_role_arn = module.iam.processor_lambda_exec_role_arn
  query_role_arn     = module.iam.query_lambda_exec_role_arn

  events_queue_url = module.sqs.event_queue_url
  events_queue_arn = module.sqs.event_queue_arn

  pydantic_layer_arn = module.lambda_layer.pydantic_layer_arn
  common_layer_arn   = module.lambda_layer.common_layer_arn

  dynamodb_table_name = module.dynamodb.dynamodb_table_name
}

module "api_gateway" {
  source = "./modules/api-gateway"

  ingestion_lambda_invoke_arn = module.lambda.ingestion_lambda_invoke_arn
  ingestion_lambda_name       = module.lambda.ingestion_lambda_name
  query_lambda_invoke_arn     = module.lambda.query_lambda_invoke_arn
  query_lambda_name           = module.lambda.query_lambda_name
}

output "events_url" {
  value = module.api_gateway.events_url
}

output "query_url" {
  value = module.api_gateway.query_url
}
