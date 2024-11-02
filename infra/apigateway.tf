# API Gatewayの作成
resource "aws_api_gateway_rest_api" "blog_api" {
  name        = "skill-up-engineering.com"
  description = "skill-up-engineering.comのAPI"
}

# API Gatewayリソースとパスの定義
resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_rest_api.blog_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "api_category" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "category"
}

resource "aws_api_gateway_resource" "api_category_id" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api_category.id
  path_part   = "{category}"
}

resource "aws_api_gateway_resource" "api_tag" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "tag"
}

resource "aws_api_gateway_resource" "api_tag_id" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api_tag.id
  path_part   = "{tag}"
}

resource "aws_api_gateway_resource" "api_year" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "{year}"
}

resource "aws_api_gateway_resource" "api_year_month" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api_year.id
  path_part   = "{month}"
}

resource "aws_api_gateway_resource" "api_year_month_day" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api_year_month.id
  path_part   = "{day}"
}

resource "aws_api_gateway_resource" "api_year_month_day_title" {
  rest_api_id = aws_api_gateway_rest_api.blog_api.id
  parent_id   = aws_api_gateway_resource.api_year_month_day.id
  path_part   = "{title}"
}

# 各リソースにGETメソッドを追加
resource "aws_api_gateway_method" "api_category_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.api_category_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "api_tag_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.api_tag_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "api_year_month_get" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.api_year_month.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "api_year_month_day_title_get" {
  rest_api_id   = aws_api_gateway_rest_api.blog_api.id
  resource_id   = aws_api_gateway_resource.api_year_month_day_title.id
  http_method   = "GET"
  authorization = "NONE"
}

# Lambdaとのインテグレーション設定
resource "aws_api_gateway_integration" "api_category_id_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.blog_api.id
  resource_id             = aws_api_gateway_resource.api_category_id.id
  http_method             = aws_api_gateway_method.api_category_id_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.blog_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "api_tag_id_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.blog_api.id
  resource_id             = aws_api_gateway_resource.api_tag_id.id
  http_method             = aws_api_gateway_method.api_tag_id_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.blog_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "api_year_month_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.blog_api.id
  resource_id             = aws_api_gateway_resource.api_year_month.id
  http_method             = aws_api_gateway_method.api_year_month_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.blog_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "api_year_month_day_title_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.blog_api.id
  resource_id             = aws_api_gateway_resource.api_year_month_day_title.id
  http_method             = aws_api_gateway_method.api_year_month_day_title_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.blog_lambda.invoke_arn
}