
# Create REST API
resource "aws_api_gateway_rest_api" "lambda_api" {
  name        = "lambda-etl-api"
  description = "API Gateway for invoking ETL Lambda"
}

# Create POST method for Lambda invocation at root ("/")
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  resource_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

# Integrate Lambda with API Gateway
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_api.id
  resource_id             = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.etl_lambda.invoke_arn
}

# Allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.etl_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

# Deploy the API Gateway
resource "aws_api_gateway_deployment" "lambda_api_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  stage_name  = "prod"
}

# Output the endpoint URL
output "api_gateway_url" {
  value = aws_api_gateway_deployment.lambda_api_deployment.invoke_url
}
