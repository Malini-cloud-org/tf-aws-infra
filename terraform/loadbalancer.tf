# Create Target Group for the Load Balancer
resource "aws_lb_target_group" "web_app_target_group" {
  name     = "web-app-target-group"
  port     = var.app_port
  protocol = "HTTP" # Protocol for the target group
  vpc_id   = aws_vpc.csye6225_vpc.id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
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

# Create a Listener for the Load Balancer
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.web_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_target_group.arn
  }
}