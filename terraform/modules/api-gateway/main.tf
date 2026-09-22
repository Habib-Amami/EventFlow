resource "aws_apigatewayv2_api" "eventflow" {
  name          = "eventflow-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "ingestion" {
  api_id                 = aws_apigatewayv2_api.eventflow.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.ingestion_lambda_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_events" {
  api_id    = aws_apigatewayv2_api.eventflow.id
  route_key = "POST /events"
  target    = "integrations/${aws_apigatewayv2_integration.ingestion.id}"
}

resource "aws_apigatewayv2_integration" "query" {
  api_id                 = aws_apigatewayv2_api.eventflow.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.query_lambda_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_event" {
  api_id    = aws_apigatewayv2_api.eventflow.id
  route_key = "GET /events/{event_id}"
  target    = "integrations/${aws_apigatewayv2_integration.query.id}"
}

resource "aws_lambda_permission" "apigw_invoke_ingestion" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.ingestion_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.eventflow.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_invoke_query" {
  statement_id  = "AllowAPIGatewayInvokeQuery"
  action        = "lambda:InvokeFunction"
  function_name = var.query_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.eventflow.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.eventflow.id
  name        = "dev"
  auto_deploy = true
}