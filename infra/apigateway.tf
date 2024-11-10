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
  path_part   = "category"
}

resource "aws_api_gateway_resource" "api_3" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api_2.id
  path_part   = "{category}"
}

resource "aws_api_gateway_resource" "api_4" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api_1.id
  path_part   = "tag"
}

resource "aws_api_gateway_resource" "api_5" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api_4.id
  path_part   = "{tag}"
}

resource "aws_api_gateway_resource" "api_6" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api_1.id
  path_part   = "{year}"
}

resource "aws_api_gateway_resource" "api_7" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api_6.id
  path_part   = "{month}"
}

resource "aws_api_gateway_resource" "api_8" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api_7.id
  path_part   = "{day}"
}

resource "aws_api_gateway_resource" "api_9" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api_8.id
  path_part   = "{title}"
}



resource "aws_api_gateway_method" "api_3_get" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.api_3.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "api_5_get" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.api_5.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "api_7_get" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.api_7.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "api_9_get" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.api_9.id
  http_method   = "GET"
  authorization = "NONE"
}



resource "aws_api_gateway_integration" "api_3_get" {
  rest_api_id             = aws_api_gateway_rest_api.blog_api.id
  resource_id             = aws_api_gateway_resource.api_3.id
  http_method             = aws_api_gateway_method.api_3_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.blog_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "api_5_get" {
  rest_api_id             = aws_api_gateway_rest_api.blog_api.id
  resource_id             = aws_api_gateway_resource.api_5.id
  http_method             = aws_api_gateway_method.api_5_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.blog_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "api_7_get" {
  rest_api_id             = aws_api_gateway_rest_api.blog_api.id
  resource_id             = aws_api_gateway_resource.api_7.id
  http_method             = aws_api_gateway_method.api_7_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.blog_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "api_9_get" {
  rest_api_id             = aws_api_gateway_rest_api.blog_api.id
  resource_id             = aws_api_gateway_resource.api_9.id
  http_method             = aws_api_gateway_method.api_9_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.blog_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "blog_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  stage_name  = "prod"
}
