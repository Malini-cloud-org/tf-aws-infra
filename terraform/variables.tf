#VPC Creation
variable "region" {
  description = "AWS region where resources will be created"
  type        = string
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
#Subnets
variable "subnet_count" {
  description = "Number of public and private subnets to create in each availability zone"
  type        = number
  validation {
    condition     = var.subnet_count > 0 && var.subnet_count <= 3
    error_message = "Subnet count must be between 1 and 3."
  }
}
