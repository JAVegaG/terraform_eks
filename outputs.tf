# output "api_url" {
#   description = "API url to consume the lambdas"
#   value       = aws_apigatewayv2_stage.stage.invoke_url
# }

# output "unique_identifier" {
#   description = "Value of the unique identifier for the resources created"
#   value       = "${var.region}-${terraform.workspace}-${random_id.name.id}"
# }

output "unique_identifier" {
  description = "Value of the unique identifier for the resources created"
  value       = random_id.name.hex
}

