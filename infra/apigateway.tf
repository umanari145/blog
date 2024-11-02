provider "aws" {
  region = "us-west-2" # Specify your region
}

# Define the API Gateway
resource "aws_api_gateway_rest_api" "blog_api" {
  name = "blogApi"
  description = "API Gateway for blog"

  # Enable X-Ray tracing
  tags = {
    TracingEnabled = "true"
  }
}

resource "aws_api_gateway_resource" "blogs_resource" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_rest_api.blog_api.root_resource_id
  path_part   = "blogs"
}

resource "aws_api_gateway_resource" "blog_resource" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_rest_api.root_resource_id
  path_part   = "blog"
}

resource "aws_api_gateway_resource" "blog_id_resource" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.blog_resource.id
  path_part   = "{id}"
}

# Define API Gateway methods and integrations
locals {
  methods = ["GET", "POST", "PUT", "DELETE"]
  paths   = ["blogs", "blog/{id}"]
}

# Create method integrations
resource "aws_api_gateway_method" "blog_api_methods" {
  for_each = {
    for method in local.methods : method => method
  }

  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.blogs_resource.id
  http_method   = each.value
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "blog_api_integration" {
  for_each = {
    for method in local.methods : method => method
  }

  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  resource_id = aws_api_gateway_resource.blogs_resource.id
  http_method = each.value
  integration_http_method = "POST"
  type                     = "AWS_PROXY"
  uri                      = aws_lambda_function.blog_lambda.invoke_arn
}

# Deploy the API
resource "aws_api_gateway_deployment" "blog_api_deployment" {
  depends_on = [aws_api_gateway_method.blog_api_methods]

  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  stage_name  = "prod"
}
