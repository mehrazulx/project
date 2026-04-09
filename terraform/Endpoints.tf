
#create endpoint service_______________________________________________________________________________

resource "aws_vpc_endpoint_service" "Endservice" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.ECS_NLB.arn]

  tags = {
    Name = "MyPrivateLinkService"
  }
}



#create endpoint PrivateLink___________________________________________________________________________
resource "aws_vpc_endpoint" "Privatelink" {
  vpc_id            = aws_vpc.Public.id
  service_name      = aws_vpc_endpoint_service.Endservice.service_name
  vpc_endpoint_type = "Interface"

  subnet_ids          = [aws_subnet.existing_public.id]
  security_group_ids  = [aws_security_group.public_sg.id]
  private_dns_enabled = false

  depends_on = [aws_vpc_endpoint_service.Endservice]
}

