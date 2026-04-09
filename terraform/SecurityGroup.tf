# Security Group________________________________________________________________________________
resource "aws_security_group" "public_sg" {
  name        = "${var.project_name}-sgTF"
  description = "Security group for ECS app"
  vpc_id      = aws_vpc.Public.id

  # Inbound Rules



  # Port 80 rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }



  # Outbound rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sgTF"
  }
}

# Security Group________________________________________________________________________________
resource "aws_security_group" "private_sg" {
  name        = "SF2"
  description = "Security group for ECS app"
  vpc_id      = aws_vpc.Private.id

  # Inbound Rules
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.1.1.0/24", "10.1.3.0/24"]
  }




  tags = {
    Name = "SF2"
  }
}
