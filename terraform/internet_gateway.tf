resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.csye6225_vpc.id

  tags = {
    Name = "${var.vpc_name}-InternetGateway"
  }
}