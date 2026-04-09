#Private subnet____________________________________________________________________________________________
resource "aws_subnet" "existing_private" {
  vpc_id                  = aws_vpc.Private.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false


  tags = {
    name = "Private-subnet-1"
  }
}

resource "aws_subnet" "existing_private_2" {
  vpc_id                  = aws_vpc.Private.id
  cidr_block              = "10.1.3.0/24"
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = false

  tags = {
    name = "Private-subnet-2"
  }
}


resource "aws_subnet" "existing_private_public" {
  vpc_id                  = aws_vpc.Private.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false


  tags = {
    name = "Public-subnet-1"
  }
}






#public
resource "aws_subnet" "existing_public" {
  vpc_id                  = aws_vpc.Public.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true


  tags = {
    name = "Public-subnet-2"
  }

}
