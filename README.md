# AWS Infrastructure Setup Using Terraform

This repository contains Terraform scripts to set up networking resources on AWS, including VPCs, public/private subnets, internet gateways, and route tables.

## Prerequisites

Ensure that the following tools are installed and configured before starting:

- **Terraform**: Download from [here](https://www.terraform.io/downloads.html).
- **AWS CLI**: Download from [here](https://aws.amazon.com/cli/).
- **AWS Account**: You will need an active AWS account to deploy resources.

### AWS CLI Configuration

- Run the following command to configure AWS CLI with your credentials:

```bash
aws configure --profile (profilename)

AWS Access Key ID [None]: YOUR_AWS_ACCESS_KEY
AWS Secret Access Key [None]: YOUR_AWS_SECRET_KEY
Default region name [None]: 
Default output format [None]: json
```

### Terraform infrastructure setup

1. Clone the repository
2. cd terraform and update the .tfvars file
3. Initialize Terraform
    `terraform init`
4. Validate Configuration
   `terraform validate`
5. Plan the infrastructure
   `terraform plan`
6. Apply the Configuration
   `terraform apply`
7. Cleanup Resources:
   `terraform destroy`