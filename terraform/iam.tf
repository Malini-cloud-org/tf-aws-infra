
# Creation of IAM role 
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# SNS Policy for EC2 Role
resource "aws_iam_policy" "sns_publish_policy" {
  name        = "SNSTopicPublishPolicy"
  description = "Policy to allow EC2 instance to publish to SNS topic"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.user_creation_topic.arn
      }
    ]
  })
}

# Attach SNS Policy to the EC2 Role
resource "aws_iam_role_policy_attachment" "attach_sns_publish_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}


# Creation of IAM Policy for S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3AccessPolicy"
  description = "Policy to allow access to the S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.s3_bucket.arn}/*", # All objects in the bucket
          aws_s3_bucket.s3_bucket.arn         # The bucket itself
        ]
      },
    ]
  })
}

# Attach policy to IAM role
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
  depends_on = [aws_s3_bucket.s3_bucket]
}


# Cloud Watch

# CloudWatch Policy for the IAM Role
data "aws_iam_policy" "cloudwatch_agent_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Attach the CloudWatchAgentServerPolicy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_cloudwatch_agent_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = data.aws_iam_policy.cloudwatch_agent_policy.arn
}

# IAM instance profile to associate the IAM role with ec2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_role_instance_profile"
  role = aws_iam_role.ec2_role.name
}



resource "aws_iam_role_policy" "secrets_manager_access" {
  name = "secrets-manager-access"

  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.db_password.arn, # Database Password
          # aws_secretsmanager_secret.email_service_credentials.arn  # SendGrid API Key
        ]
      },

      {
        Effect : "Allow",
        Action : [
          "kms:Decrypt"
        ],
        Resource : [
          "arn:aws:kms:${var.region}:${var.aws_account_id}:key/${aws_kms_key.secrets_kms_key.id}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_secrets_manager_access" {
  name = "lambda-secrets-manager-access"

  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.email_service_credentials.arn # Only the SendGrid API Key
      },

      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt"
        ],
        Resource = aws_kms_key.secrets_kms_key.arn
      }
    ]
  })
}
