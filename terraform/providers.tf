provider "aws" {
  region  = var.region
  profile = "dev"  # Ensure this matches your AWS CLI profile
}