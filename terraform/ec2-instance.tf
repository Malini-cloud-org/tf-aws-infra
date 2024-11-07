
# resource "aws_instance" "web_app" {
#   ami                         = var.ami_id
#   instance_type               = var.instance_type
#   subnet_id                   = aws_subnet.public[0].id
#   associate_public_ip_address = true # Ensure it gets a public IP
#   vpc_security_group_ids      = [aws_security_group.app_sg.id]
#   # key_name                    = var.key_name #ssh key name for ec2
#   root_block_device {
#     volume_size           = 25
#     volume_type           = "gp2"
#     delete_on_termination = true
#   }

#   disable_api_termination = false # Allow termination

#   # Attach IAM role using instance profile
#   iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

#   user_data = <<-EOF
# #!/bin/bash
# set -e
# set -x

# sudo chown -R csye6225:csye6225 /opt/webapp
# cd /opt/webapp/service || { echo "Directory /opt/webapp/service not found!"; exit 1; }

# DB_HOST="${aws_db_instance.rds_instance.address}"
# DB_PORT="${var.db_port}"
# DB_NAME="${var.db_name}"
# DB_USERNAME="${var.db_username}"
# DB_PASSWORD="${var.db_password}"
# DB_DIALECT="${var.db_engine}"
# PORT="${var.app_port}"
# S3_BUCKET_NAME="${aws_s3_bucket.s3_bucket.id}"
# AWS_REGION="${var.region}"


# echo "Updating .env file with dynamic variables..."
# cat <<EOT | sudo tee /opt/webapp/service/.env > /dev/null
# DB_HOST=$DB_HOST
# DB_PORT=$DB_PORT
# DB_NAME=$DB_NAME
# DB_USERNAME=$DB_USERNAME
# DB_PASSWORD=$DB_PASSWORD
# DB_DIALECT=$DB_DIALECT
# S3_BUCKET_NAME=$S3_BUCKET_NAME
# AWS_REGION=$AWS_REGION

# PORT=$PORT
# EOT

# echo "Updated .env succesfully"

# # Validate .env creation
# if [ ! -f /opt/webapp/service/.env ]; then
#   echo ".env file creation failed!"
#   exit 1
# fi

# sudo chown csye6225:csye6225 /opt/webapp/service/.env

# #Configure Cloudwatch agent
# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/cloudwatch_config.json -s

# sudo systemctl enable amazon-cloudwatch-agent
# sudo systemctl restart amazon-cloudwatch-agent

# #Restart service file
# sudo systemctl daemon-reload
# sudo systemctl enable csye6225-aws.service

# echo "Restarting csye6225-aws.service..."
# sudo systemctl restart csye6225-aws.service

# echo "Checking csye6225-aws.service..."
# sudo systemctl status csye6225-aws.service --no-pager
# EOF

#   depends_on = [aws_db_instance.rds_instance]
#   tags = {
#     Name = "web_app_instance"
#   }
# }

# output "instance_public_ip" {
#   value       = aws_instance.web_app.public_ip
#   description = "The public IP address of the web application instance."
# }


# Subnet Group for RDS to ensure deployment in private subnet
resource "aws_db_subnet_group" "rds_private_subnet_group" {
  name        = var.db_subnet_group_name
  description = "Private subnet group for RDS"
  subnet_ids  = aws_subnet.private[*].id //List of private subnet ids

  depends_on = [aws_subnet.private]
  tags = {
    Name = var.db_subnet_group_name
  }
}
resource "aws_db_instance" "rds_instance" {
  identifier             = var.db_instance_identifier
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  parameter_group_name   = aws_db_parameter_group.postgres_parameter_group.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_private_subnet_group.name
  publicly_accessible    = false
  multi_az               = var.multi_az
  skip_final_snapshot    = true

  depends_on = [
    aws_db_subnet_group.rds_private_subnet_group,
    aws_security_group.db_security_group
  ]
  tags = {
    Name = var.db_instance_identifier
  }
}


