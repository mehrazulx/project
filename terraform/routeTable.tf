# Private route table______________________________________________________________________________________
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.Private.id

  tags = {
    Name = "VPC-Private-RT"
  }
}


# Private route table______________________________________________________________________________________
resource "aws_route_table" "private_public" {
  vpc_id = aws_vpc.Private.id

  tags = {
    Name = "VPC-Private-public-RT"
  }
}





#public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.Public.id

  tags = {
    Name = "VPC-public-RT"
  }
}



# Associate private subnet with  route table________________________________________________________________________________
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.existing_private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.existing_private_2.id
  route_table_id = aws_route_table.private.id
}



# Associate private/public subnet with  route table________________________________________________________________________________
resource "aws_route_table_association" "private_public" {
  subnet_id      = aws_subnet.existing_private_public.id
  route_table_id = aws_route_table.private_public.id
}




#asssociate public subnet with route table------------------------------------------------------------------
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.existing_public.id
  route_table_id = aws_route_table.public.id
}

