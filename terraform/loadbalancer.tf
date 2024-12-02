# Create Target Group for the Load Balancer
resource "aws_lb_target_group" "web_app_target_group" {
  name     = "web-app-target-group"
  port     = var.app_port
  protocol = "HTTP" # Protocol for the target group
  vpc_id   = aws_vpc.csye6225_vpc.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 120
    path                = "/healthz"
  }

  tags = {
    Name = "web-app-target-group"
  }
}

# Create Load Balancer
resource "aws_lb" "web_app_lb" {
  name               = "web-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id] # Using public subnets

  # enable_deletion_protection = false  # Set to true to protect from accidental deletion


  tags = {
    Name = "web-app-lb"
  }
}

#Issued certificate
data "aws_acm_certificate" "issued" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}
# Create a Listener for the Load Balancer
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.web_app_lb.arn
  # port              = 80
  # protocol          = "HTTP"
  port     = 443
  protocol = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.issued.arn
  # certificate_arn = "arn:aws:acm:us-east-1:273354658804:certificate/31758b89-c015-421b-973d-d151b18b772c"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_target_group.arn
  }
}