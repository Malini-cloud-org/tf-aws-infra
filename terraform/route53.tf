data "aws_route53_zone" "existing_zone" {
  name         = var.domain_name
  private_zone = false
}

# Define the A record to point to the EC2 instance
resource "aws_route53_record" "ec2_a_record" {
  zone_id = data.aws_route53_zone.existing_zone.zone_id # Use the Route 53 zone ID
  name    = var.domain_name
  type    = "A"
  ttl     = 60 # Time to Live (TTL)

  # Pointing to the EC2 instance's public IP
  records = [aws_instance.web_app.public_ip] # Reference to EC2 instance's public IP

  # Ensure the A record is created only after the EC2 instance is up
  depends_on = [
    aws_instance.web_app
  ]
}