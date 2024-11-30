# API Gatewayの作成
resource "aws_api_gateway_rest_api" "blog_api" {
  name        = "blog_api"
  description = "skill-up-engineering.comのblog"
}


resource "aws_api_gateway_resource" "api_1" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_rest_api.blog_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "api_2" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api_1.id
  path_part   = "blogs"
}

resource "aws_api_gateway_resource" "api_3" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api_2.id
  path_part   = "{post_no}"
}



resource "aws_api_gateway_method" "api_2_get" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.api_2.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "api_3_get" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.api_3.id
  http_method   = "GET"
  authorization = "NONE"
}



resource "aws_api_gateway_integration" "api_2_get" {
  rest_api_id             = aws_api_gateway_rest_api.blog_api.id
  resource_id             = aws_api_gateway_resource.api_2.id
  http_method             = aws_api_gateway_method.api_2_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.blog_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "api_3_get" {
  rest_api_id             = aws_api_gateway_rest_api.blog_api.id
  resource_id             = aws_api_gateway_resource.api_3.id
  http_method             = aws_api_gateway_method.api_3_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.blog_lambda.invoke_arn
}


resource "aws_api_gateway_deployment" "blog_api_deployment" {
  depends_on  = [aws_api_gateway_rest_api.blog_api]
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  stage_name  = "prod"
}