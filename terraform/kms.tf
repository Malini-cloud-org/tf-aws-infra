# Random Password resource
resource "random_password" "db_password" {
  length           = var.password_length
  special          = var.password_special
  override_special = var.password_override_special

}

resource "random_string" "secret_suffix" {
  length  = 8
  upper   = false
  special = false
}

# KMS Key for ebs volume
resource "aws_kms_key" "ebs_kms_key" {

  description              = "KMS key for EC2 encryption"
  enable_key_rotation      = true
  rotation_period_in_days  = 90
  deletion_window_in_days  = 10
  customer_master_key_spec = "SYMMETRIC_DEFAULT"



  policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions"
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },

      {
        "Sid" : "Allow access for Key Administrators",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        "Resource" : "*"
      },

      {
        Sid : "Allow AutoScaling to use the key"
        Effect : "Allow",
        Principal : {
          "AWS" : "arn:aws:iam::${var.aws_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        "Resource" : "*"
      },
      {
        "Sid" : "Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      }
    ]
  })
  tags = {
    Name = "ebs-kms-key"
  }

}

resource "aws_kms_alias" "ebs_kms_key_alias" {
  name          = "alias/ebs-kms-key"
  target_key_id = aws_kms_key.ebs_kms_key.id
}

# KMS Key for RDS
resource "aws_kms_key" "rds_kms_key" {
  description              = "KMS key for RDS encryption"
  enable_key_rotation      = true
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  rotation_period_in_days  = 90
  deletion_window_in_days  = 10

  policy = jsonencode(

    {
      "Id" : "key-for-rds",
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "Enable IAM User Permissions",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${var.aws_account_id}:root"
          },
          "Action" : "kms:*",
          "Resource" : "*"
        },
        {
          "Sid" : "Allow access for Key Administrators",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${var.aws_account_id}:role/ec2_role"
          },
          "Action" : [
            "kms:Create*",
            "kms:Describe*",
            "kms:Enable*",
            "kms:List*",
            "kms:Put*",
            "kms:Update*",
            "kms:Revoke*",
            "kms:Disable*",
            "kms:Get*",
            "kms:Delete*",
            "kms:TagResource",
            "kms:UntagResource",
            "kms:ScheduleKeyDeletion",
            "kms:CancelKeyDeletion"
          ],
          "Resource" : "*"
        },

        {
          "Sid" : "Allow RDS Service Access",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${var.aws_account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
          },
          "Action" : [
            "kms:Create*",
            "kms:Describe*",
            "kms:Enable*",
            "kms:List*",
            "kms:Put*",
            "kms:Update*",
            "kms:Revoke*",
            "kms:Disable*",
            "kms:Get*",
            "kms:Delete*",
            "kms:TagResource",
            "kms:UntagResource",
            "kms:ScheduleKeyDeletion",
            "kms:CancelKeyDeletion"
          ],
          "Resource" : "*"
        }
        ,
        {
          "Sid" : "Allow use of the key",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${var.aws_account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
          },
          "Action" : [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ],
          "Resource" : "*"
        },

        {
          "Sid" : "Allow use of the key for ec2",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${var.aws_account_id}:role/ec2_role"
          },
          "Action" : [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "Allow attachment of persistent resources",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${var.aws_account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
          },
          "Action" : [
            "kms:CreateGrant",
            "kms:ListGrants",
            "kms:RevokeGrant"
          ],
          "Resource" : "*",
          "Condition" : {
            "Bool" : {
              "kms:GrantIsForAWSResource" : "true"
            }
          }
        }
      ]
    }

  )

  tags = {
    Name = "rds-kms-key"
  }
}

resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/rds-kms-key"
  target_key_id = aws_kms_key.rds_kms_key.id
}


# KMS Key for S3
resource "aws_kms_key" "s3_kms_key" {
  description              = "KMS key for S3 encryption"
  enable_key_rotation      = true
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  rotation_period_in_days  = 90
  deletion_window_in_days  = 10

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access for S3 buckets",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_id}:role/ec2_role"
        }
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        "Resource" : "*"
      }
    ]
  })
  tags = {
    Name = "s3-kms-key"
  }
}

resource "aws_kms_alias" "s3_kms_key_alias" {
  name          = "alias/s3-manager-kms-key"
  target_key_id = aws_kms_key.s3_kms_key.id
}

# KMS Key for Secrets Manager
resource "aws_kms_key" "secrets_kms_key" {
  description              = "KMS key for Secrets Manager"
  enable_key_rotation      = true
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  rotation_period_in_days  = 90
  deletion_window_in_days  = 10


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Allow Secrets Manager to use the key",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "secretsmanager.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        Sid : "AllowEC2RoleDecryptAccess",
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${var.aws_account_id}:role/${aws_iam_role.ec2_role.name}"
        },
        Action : "kms:Decrypt",
        Resource : "*"
      },
      {
        "Sid" : "Allow access for Key Administrators",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_id}:user/demo_aws_cli"
        },
        "Action" : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
          "kms:RotateKeyOnDemand",
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = {
    Name = "secret-manager-kms-key"
  }
}

resource "aws_kms_alias" "secrets_kms_key_alias" {
  name          = "alias/secrets-manager-kms-key"
  target_key_id = aws_kms_key.secrets_kms_key.id
}

resource "aws_secretsmanager_secret" "db_password" {
  name        = "db_password_${random_string.secret_suffix.result}"
  description = "Database password for RDS instance"
  kms_key_id  = aws_kms_key.secrets_kms_key.arn # Use the KMS key for encryption

  tags = {
    Name = "db_password_secret"
  }
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    password = random_password.db_password.result
  })
}

resource "aws_secretsmanager_secret" "email_service_credentials" {
  name        = "email_service_credentials_${random_string.secret_suffix.result}"
  description = "Email service credentials for sending emails"
  kms_key_id  = aws_kms_key.secrets_kms_key.arn # Use the same KMS key

  tags = {
    Name = "email_service_credentials_secret"
  }

}

resource "aws_secretsmanager_secret_version" "email_service_credentials_version" {
  secret_id = aws_secretsmanager_secret.email_service_credentials.id
  secret_string = jsonencode({
    sendgrid_api_key = var.sendgrid_api_key
    email_sender     = var.email_sender
  })
}
