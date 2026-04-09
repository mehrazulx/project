# ECS Cluster________________________________________________________________________________
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}


# ECS Service________________________________________________________________________________
resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on      = [aws_lb_listener.ECS_NLB_Listener]

  network_configuration {
    subnets          = [aws_subnet.existing_private.id, aws_subnet.existing_private_2.id]
    security_groups  = [aws_security_group.private_sg.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ECS_TG.arn
    container_name   = "app"
    container_port   = 3000
  }
}
