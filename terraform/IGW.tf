#create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Public.id

  tags = {
    Name = "VPC-IGW"
  }
}

resource "aws_internet_gateway" "igw-priv" {
  vpc_id = aws_vpc.Private.id

  tags = {
    Name = "VPC-IGW-2"
  }
}

#route IGW with public Route table
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#route IGW with public Route table
resource "aws_route" "public_internet_access_2" {
  route_table_id         = aws_route_table.private_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw-priv.id
}

