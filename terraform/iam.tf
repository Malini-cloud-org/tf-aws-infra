
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

