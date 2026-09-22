output "events_url" {
  description = "URL for the POST /events endpoint"
  value       = "${aws_apigatewayv2_api.eventflow.api_endpoint}/dev/events"
}

output "query_url" {
  description = "URL template for the GET /events/{event_id} endpoint"
  value       = "${aws_apigatewayv2_api.eventflow.api_endpoint}/dev/events/{event_id}"
}