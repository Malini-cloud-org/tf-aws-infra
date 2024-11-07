data "template_file" "user_data" {

  template = <<-EOF
#!/bin/bash
set -e
set -x

sudo chown -R csye6225:csye6225 /opt/webapp
cd /opt/webapp/service || { echo "Directory /opt/webapp/service not found!"; exit 1; }

DB_HOST="${aws_db_instance.rds_instance.address}"
DB_PORT="${var.db_port}"
DB_NAME="${var.db_name}"
DB_USERNAME="${var.db_username}"
DB_PASSWORD="${var.db_password}"
DB_DIALECT="${var.db_engine}"
PORT="${var.app_port}"
S3_BUCKET_NAME="${aws_s3_bucket.s3_bucket.id}"
AWS_REGION="${var.region}"


echo "Updating .env file with dynamic variables..."
cat <<EOT | sudo tee /opt/webapp/service/.env > /dev/null
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD
DB_DIALECT=$DB_DIALECT
S3_BUCKET_NAME=$S3_BUCKET_NAME
AWS_REGION=$AWS_REGION

PORT=$PORT
EOT

echo "Updated .env succesfully"

# Validate .env creation
if [ ! -f /opt/webapp/service/.env ]; then
  echo ".env file creation failed!"
  exit 1
fi

sudo chown csye6225:csye6225 /opt/webapp/service/.env

#Configure Cloudwatch agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/cloudwatch_config.json -s

sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl restart amazon-cloudwatch-agent

#Restart service file
sudo systemctl daemon-reload
sudo systemctl enable csye6225-aws.service

echo "Restarting csye6225-aws.service..."
sudo systemctl restart csye6225-aws.service

echo "Checking csye6225-aws.service..."
sudo systemctl status csye6225-aws.service --no-pager
EOF


}




resource "aws_launch_template" "csye6225_asg" {
  name_prefix   = "csye6225-asg"
  image_id      = var.ami_id        # Custom AMI ID
  instance_type = var.instance_type # Instance type
  key_name      = var.key_name      # SSH key pair

  network_interfaces {
    associate_public_ip_address = true                           # Associate a public IP
    security_groups             = [aws_security_group.app_sg.id] # Use web app security group
  }

  lifecycle {
    create_before_destroy = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(data.template_file.user_data.rendered) # Use the template with Base64 encoding


}
