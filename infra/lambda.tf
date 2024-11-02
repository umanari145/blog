# Define the Lambda function
resource "aws_lambda_function" "blog_lambda" {
  filename         = "path/to/your/lambda_function.zip" # Update with the path to your Lambda package
  function_name    = "blogLambdaFunction"
  handler          = "app.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 128
  timeout          = 20
  architectures    = ["x86_64"]

  # Enable X-Ray tracing
  tracing_config {
    mode = "Active"
  }

  # Log settings
  environment {
    variables = {
      LogFormat = "JSON"
    }
  }
  # Define Lambda execution role
  role = aws_iam_role.lambda_exec_role.arn
}


# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  # Attach necessary policies
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  ]
}

# Lambda permission for API Gateway to invoke
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.blog_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.blog_api.execution_arn}/*/*"
}

