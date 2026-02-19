resource "aws_ecs_cluster" "this" {
  name = "${var.prefix}-cluster"

  tags = var.tags
}

resource "aws_ecs_service" "this" {
  name            = "${var.prefix}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = var.task_definition_arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = var.security_groups
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}
