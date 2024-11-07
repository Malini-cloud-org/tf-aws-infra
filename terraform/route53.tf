data "aws_route53_zone" "existing_zone" {
  name         = var.domain_name
  private_zone = false
}

# Define the A record to point to the EC2 instance
resource "aws_route53_record" "load_balancer_record" {
  zone_id = data.aws_route53_zone.existing_zone.zone_id # Use the Route 53 zone ID
  name    = var.domain_name
  type    = "A"
  # ttl     = 60 # Time to Live (TTL)


  # Pointing to the EC2 instance's public IP
  # records = [aws_instance.web_app.public_ip] # Reference to EC2 instance's public IP


  # Pointing to the Application Load Balancer
  alias {
    name                   = aws_lb.web_app_lb.dns_name
    zone_id                = aws_lb.web_app_lb.zone_id
    evaluate_target_health = true # Set to true to enable health checks
  }

  # Ensure the A record is created only after the EC2 instance is up
  depends_on = [
    aws_lb.web_app_lb
  ]
}