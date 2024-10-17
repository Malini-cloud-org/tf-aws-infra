data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.csye6225_vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*PublicSubnet-*"]
  }
}



resource "aws_instance" "web_app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = element(data.aws_subnets.public.ids, 0)
  associate_public_ip_address = true # Ensure it gets a public IP
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  disable_api_termination = false # Allow termination

  tags = {
    Name = "web_app_instance"
  }
}

output "instance_public_ip" {
  value       = aws_instance.web_app.public_ip
  description = "The public IP address of the web application instance."
}