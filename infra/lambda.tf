data "archive_file" "archive_zip" {
  type        = "zip"
  source_dir  = "../app"
  output_path = "../app/lambda_function.zip"
}

# Define the Lambda function
resource "aws_lambda_function" "blog_lambda" {
  filename         = data.archive_file.archive_zip.output_path
  function_name    = "blogLambdaFunction"
  handler          = "lambda_function.handler"
  runtime          = "python3.12"
  memory_size      = 128
  timeout          = 20
  architectures    = ["x86_64"]
  source_code_hash = filebase64sha256(data.archive_file.archive_zip.output_path)
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
}

# managed_policyのattachはこれで
resource "aws_iam_role_policy_attachments_exclusive" "managed_policy" {
  role_name      = aws_iam_role.lambda_exec_role.name
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
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

