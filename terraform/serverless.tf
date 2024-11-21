# Create SNS Topic
resource "aws_sns_topic" "user_creation_topic" {
  name         = var.sns_topic_name
  display_name = var.sns_display_name
}


# Lambda IAM Role for Lambda Function to access SNS
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policy to the role for SNS access
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = aws_sns_topic.user_creation_topic.arn
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_cloudwatch_log_group.lambda_log_group.arn}:*"
        ]
      },
      {
        Action = [
          "logs:CreateLogGroup"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.lambda_log_group.arn}"
      }
    ]
  })
}

# Attach AWSLambdaBasicExecutionRole managed policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "basic_execution_role" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
# Lambda Function (Using Node.js 18 and referencing the local zip file from the serverless repo)
resource "aws_lambda_function" "send_email_lambda" {
  function_name = "send-email-lambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  # Reference to the Lambda deployment package (use the local path to the zip file)
  filename = var.lambda_deployment_package_path

  environment {
    variables = {
      #   SENDGRID_API_KEY = jsondecode(aws_secretsmanager_secret_version.sendgrid_api_secret_version.secret_string)["api_key"]
      SENDGRID_API_KEY = var.sendgrid_api_key
      EMAIL_SENDER     = var.email_sender
      BASE_URL         = var.base_url
      # SNS_TOPIC_ARN    = aws_sns_topic.user_creation_topic.arn
    }
  }

  # Set Lambda timeout and memory size from variables
  timeout     = var.lambda_timeout     # Lambda function timeout
  memory_size = var.lambda_memory_size # Lambda memory size
}

# CloudWatch Log Group for Lambda function
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.send_email_lambda.function_name}"

  retention_in_days = 7
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_email_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_creation_topic.arn
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.user_creation_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.send_email_lambda.arn
}

# resource "aws_secretsmanager_secret" "sendgrid_api_secret" {
#   name = "sendgrid_api_secret"
# }
# resource "aws_secretsmanager_secret_version" "sendgrid_api_secret_version" {
#   secret_id = aws_secretsmanager_secret.sendgrid_api_secret.id
#   secret_string = jsonencode({
#     api_key      = var.sendgrid_api_key
#     sender_email = var.email_sender
#   })
# }


