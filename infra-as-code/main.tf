# Data source for the existing Counter Lambda function
data "aws_lambda_function" "counter" {
  function_name = "counter_function" 
}

# Data source for the existing Send Email Lambda function
data "aws_lambda_function" "send_email" {
  function_name = "send_email_function" 
}

# Data source to fetch the existing IAM role
data "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
}


# Data source to fetch the existing IAM policy
data "aws_iam_policy" "iam_for_project" {
  arn = "arn:aws:iam::423623825342:policy/aws_iam_policy_for_project"
}

# Attach the existing IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_policy_to_iam_role" {
    role       = data.aws_iam_role.iam_for_lambda.name
    policy_arn = data.aws_iam_policy.iam_for_project.arn
}

# Data source to create a ZIP archive of the Lambda function code for counter
data "archive_file" "counter_zip" {
    type        = "zip"
    source_dir  = "${path.module}/lambda/"
    output_path = "${path.module}/packedlambda.zip"
}

# Data source to create a ZIP archive of the Lambda function code for sending email
data "archive_file" "send_email_zip" {
    type        = "zip"
    source_dir  = "${path.module}/lambda/"
    output_path = "${path.module}/packedlambda.zip"
}

# Reference existing Lambda Function URL for counter_function
data "aws_lambda_function_url" "url1" {
  function_name = data.aws_lambda_function.counter.function_name
}

# Reference existing Lambda Function URL for send_email_function
data "aws_lambda_function_url" "url2" {
  function_name = data.aws_lambda_function.send_email.function_name
}

# Data source to fetch the existing DynamoDB table
data "aws_dynamodb_table" "cloud_resume_test" {
  name = "cloud-resume-test"
}

# API Gateway for the resume project
resource "aws_apigatewayv2_api" "api" {
    name          = "cloud-resume-api"
    protocol_type = "HTTP"

    cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
    expose_headers = []
    max_age = 3600
  }
}

# API Integration with the Counter Lambda function
resource "aws_apigatewayv2_integration" "counter_lambda_integration" {
    api_id             = aws_apigatewayv2_api.api.id
    integration_type   = "AWS_PROXY"
    integration_uri    = data.aws_lambda_function.counter.invoke_arn
    integration_method = "POST"
    payload_format_version = "2.0"
}

# API Route definition for the Counter Lambda
resource "aws_apigatewayv2_route" "counter_lambda_route" {
    api_id    = aws_apigatewayv2_api.api.id
    route_key = "GET /resume"

    target = "integrations/${aws_apigatewayv2_integration.counter_lambda_integration.id}"
}

# API Integration with the Send Email Lambda function
resource "aws_apigatewayv2_integration" "send_email_lambda_integration" {
    api_id             = aws_apigatewayv2_api.api.id
    integration_type   = "AWS_PROXY"
    integration_uri    = data.aws_lambda_function.send_email.invoke_arn
    integration_method = "POST"
    payload_format_version = "2.0"
}

# API Route definition for the Send Email Lambda
resource "aws_apigatewayv2_route" "send_email_lambda_route" {
    api_id    = aws_apigatewayv2_api.api.id
    route_key = "POST /send-email"

    target = "integrations/${aws_apigatewayv2_integration.send_email_lambda_integration.id}"
}

# Deployment configuration for the API
resource "aws_apigatewayv2_stage" "default_stage" {
    api_id      = aws_apigatewayv2_api.api.id
    name        = "$default"
    auto_deploy = true
}

# Permission for API Gateway to invoke Counter Lambda
resource "aws_lambda_permission" "apigw_counter_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeCounter-${random_id.unique_suffix.hex}"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# Permission for API Gateway to invoke Send Email Lambda
resource "aws_lambda_permission" "apigw_send_email_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeSendEmail-${random_id.unique_suffix.hex}"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.send_email.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# Generate unique suffix for statement IDs
resource "random_id" "unique_suffix" {
  byte_length = 4
}
