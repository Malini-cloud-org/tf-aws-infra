// subnets.tf
data "aws_availability_zones" "available" {}

# Count the number of AZs to use
locals {
  az_count = length(data.aws_availability_zones.available.names)
  subnet_count = var.subnet_count > local.az_count ? local.az_count : var.subnet_count
}
resource "aws_subnet" "public" {
  count             =                              local.subnet_count
  vpc_id            = aws_vpc.csye6225_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.csye6225_vpc.cidr_block, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = local.subnet_count
  vpc_id            = aws_vpc.csye6225_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.csye6225_vpc.cidr_block, 8, count.index + local.subnet_count)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "PrivateSubnet-${count.index + 1}"
  }
}
