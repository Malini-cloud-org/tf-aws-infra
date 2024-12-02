#VPC Creation
variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "aws_profile" {
  type        = string
  description = "Profile to use for accessing aws"
  default     = "dev"

}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID of the custom image."
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t2.small"
}

variable "app_port" {
  description = "The port on which the application will run."
  type        = number
  default     = 3000
}

variable "db_port" {
  description = "The port on which the application will run."
  type        = number
  default     = 5432
}
#Subnets
variable "subnet_count" {
  description = "Number of public and private subnets to create in each availability zone"
  type        = number
  validation {
    condition     = var.subnet_count > 0 && var.subnet_count <= 3
    error_message = "Subnet count must be between 1 and 3."
  }
}

//Variable for ssh key name
variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instance"
  type        = string
  default     = "ec2"
}
//RDS

variable "rds_parameter_group_name" {
  type        = string
  description = "Name for the custom RDS parameter group"
  default     = "csye6225-rds-parameter-group"
}

variable "pg_family" {
  type        = string
  description = "RDS family version"
  default     = "postgres16"
}


variable "app_security_group_name" {
  description = "Name of the security group for the application EC2 instance"
  default     = "app-security-group"
}

variable "db_security_group_name" {
  description = "Name of the security group for the database"
  default     = "database-security-group"
}


//From here

variable "db_instance_identifier" {
  description = "Identifier for the RDS instance"
  default     = "csye6225"
}

variable "db_engine" {
  type        = string
  default     = "postgres"
  description = "Database engine type"
}
variable "db_engine_version" {
  type        = string
  description = "Version of PostgreSQL to be used"
  default     = "16"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  type        = number
  description = "Allocated storage in GB for the RDS instance"
  default     = 20
}

variable "db_username" {
  type        = string
  description = "Master username for the RDS instance"
  default     = "csye6225"
}

# variable "db_password" {
#   type        = string
#   description = "Master password for the RDS instance"
#   sensitive   = true # Ensures it is not displayed in logs
#   default     = "Yk867-tSjz>d"
# }

variable "db_name" {
  type        = string
  description = "Name of the database to be created"
  default     = "csye6225"
}

variable "db_subnet_group_name" {
  description = "Name for the RDS subnet group"
  default     = "rds-private-subnet-group"
}


variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment (optional)"
  default     = false

}


variable "domain_name" {
  description = "The name of the Route 53 hosted zone"
  type        = string
  default     = "dev.skydev.me"
}

variable "min_size" {
  description = "Minimum number of instances in the auto-scaling group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the auto-scaling group"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired number of instances in the auto-scaling group"
  type        = number
  default     = 1
}

variable "cooldown" {
  description = "Cooldown period for auto-scaling policies"
  type        = number
  default     = 60
}

variable "scale_up_threshold" {
  description = "Threshold for scale up alarm (CPU utilization percentage)"
  type        = number
  default     = 10
}

variable "scale_up_period" {
  description = "Period for scale up alarm (in seconds)"
  type        = number
  default     = 60
}

variable "scale_up_evaluation_periods" {
  description = "Number of evaluation periods for scale up alarm"
  type        = number
  default     = 1
}

variable "scale_down_threshold" {
  description = "Threshold for scale down alarm (CPU utilization percentage)"
  type        = number
  default     = 7
}

variable "scale_down_period" {
  description = "Period for scale down alarm (in seconds)"
  type        = number
  default     = 60
}

variable "scale_down_evaluation_periods" {
  description = "Number of evaluation periods for scale down alarm"
  type        = number
  default     = 1
}


variable "sns_topic_name" {
  description = "The name of the SNS topic for user creation"
  type        = string
  default     = "user-creation-topic"
}

variable "sns_display_name" {
  description = "The display name of the SNS topic"
  type        = string
  default     = "User Creation SNS Topic"
}

variable "sns_topic_policy" {
  description = "The policy for SNS topic"
  type        = string
  default     = "{}"
}

# Lambda function timeout in seconds (up to 15 minutes = 900 seconds)
variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 900 # Default value: 15 minutes
}

# Lambda function memory size in MB
variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128 # Default memory size
}

# Path to the Lambda function deployment package (the ZIP file)
variable "lambda_deployment_package_path" {
  description = "The local path to the Lambda function zip package"
  type        = string
  default     = "./serverless.zip" # Update with correct local path
}

# Variable to specify the sender email address
variable "email_sender" {
  description = "The sender email address for sending verification emails"
  type        = string
  default     = "no-reply@dev.skydev.me"
}

#Variable for the base URL for the email verification link
variable "base_url" {
  description = "The base URL of the web application for email verification link"
  type        = string
  default     = "http://dev.skydev.me"
}

variable "sendgrid_api_key" {
  description = "SendGrid API Key"
  type        = string
  default     = "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"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "273354658804" #demo
}

variable "password_length" {
  description = "The length of the database password"
  type        = number
  default     = 16 # Default value can be changed as per your requirements
}

variable "password_special" {
  description = "Whether to include special characters in the password"
  type        = bool
  default     = true
}

variable "password_override_special" {
  description = "Custom special characters for the password"
  type        = string
  default     = "!#$%&*()-_=+[]{}<>:?"
}
