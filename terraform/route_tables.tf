# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.csye6225_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # Route for all internet traffic
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.vpc_name}-PublicRouteTable"
  }
}

resource "aws_route_table_association" "public" {
  count          = local.subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.csye6225_vpc.id

  tags = {
    Name = "${var.vpc_name}-PrivateRouteTable"
  }
}

resource "aws_route_table_association" "private" {
  count          = local.subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}