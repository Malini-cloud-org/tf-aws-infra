resource "aws_security_group" "app_sg" {
  name        = "application_security_group"
  description = "Security group for web application"

  vpc_id     = aws_vpc.csye6225_vpc.id # Reference the dynamically created VPC
  depends_on = [aws_vpc.csye6225_vpc]

  ingress {
    description     = "SSH access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    # cidr_blocks     = ["0.0.0.0/0"]                            // Only for testing
    security_groups = [aws_security_group.load_balancer_sg.id] # Allow traffic only from the load balancer
  }

  # ingress {
  #   description = "HTTP access"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   description = "HTTPS access"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    description = "Custom app port access"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.load_balancer_sg.id] # Allow traffic only from the load balancer
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


// Security group for database
# Database Security Group
resource "aws_security_group" "db_security_group" {
  name        = var.db_security_group_name
  description = "Database security group for PostgreSQL RDS instance"
  vpc_id      = aws_vpc.csye6225_vpc.id

  # Allow inbound traffic from the application security group
  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  # Allow all outbound traffic (default AWS behavior)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.db_security_group_name
  }
}

//A07 
//Load Balancer security group

# Load Balancer Security Group
resource "aws_security_group" "load_balancer_sg" {
  name        = "load-balancer-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.csye6225_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Load balancer security group"
  }
}
