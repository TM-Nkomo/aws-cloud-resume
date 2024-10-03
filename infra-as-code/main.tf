# AWS Lambda Function for Counting
resource "aws_lambda_function" "counter" {
    filename = data.archive_file.zip.output_path
    source_code_hash = data.archive_file.zip.output_base64sha256
    function_name = "counter_function"
    role = aws_iam_role.iam_for_lambda.arn
    handler = "counter_function.lambda_handler"
    runtime = "python3.9"
}

# IAM Role for the Lambda Function
resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"

    # Assume role policy that allows Lambda to assume this role
    assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
}

# IAM Policy for managing the project resources
resource "aws_iam_policy" "iam_for_project" {
  name = "aws_iam_policy_for_project"
  path = "/"
  description = "AWA IAM Policy for managing the resume project role"

  # Policy document allowing actions on CloudWatch and DynamoDB
  policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement" : [
            {
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEventts"
                ],
                "Resource": "arn:aws:logs:*:*:*",
                "Effect": "Allow"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "dynamodb:UpdateItem",
                    "dynamodb:GetItem",
                    "dynamodb:PutItem"
                ],
                "Resource": "arn:aws:dynamodb:*:*:table/cloud-resume-test"
            }
        ]
    })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_policy_to_iam_role" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_for_project.arn
}

# Data source to create a ZIP archive of the Lambda function code
data "archive_file" "zip" {
    type = "zip"
    source_dir = "${path.module}/lambda/"
    output_path = "${path.module}/packedlambda.zip"
}

# Lambda Function URL configuration
resource "aws_lambda_function_url" "url1" {
  function_name = aws_lambda_function.counter.function_name 
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = [ "date", "keep-alive" ]
    expose_headers = ["keep-alive", "date"]
    max_age = 86400
  }
}

# DynamoDB Table configuration
resource "aws_dynamodb_table" "table" {
  name           = "cloud-resume-test"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  
  attribute {
    name = "id"
    type = "S"
  }
}

# API Gateway for the resume project
resource "aws_apigatewayv2_api" "api" {
  name          = "cloud-resume-api"
  protocol_type = "HTTP"
}

# API Integration with the Lambda function
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.counter.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

# API Route definition
resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /resume"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Deployment configuration for the API
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# Output configuration for the API Gateway URL
output "api_gateway_url" {
  value = "${aws_apigatewayv2_api.api.api_endpoint}/resume"
}

# testing backend cicd 4
