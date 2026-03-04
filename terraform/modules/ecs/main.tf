###############################################################################
# ECS Module
#
# Creates:
#   - ECS Cluster with Container Insights
#   - Task Definition (Fargate)
#   - ECS Service with deployment circuit breaker + rollback
#   - ECS Service Auto Scaling (CPU and memory target tracking)
# 
# Production defaults:
#   - Container Insights enabled
#   - Circuit breaker with automatic rollback
#   - Fargate + FARGATE_SPOT capacity providers
#   - No public IP on tasks
###############################################################################

###############################################################################
# ECS Cluster
###############################################################################
resource "aws_ecs_cluster" "this" {
  name = "${var.prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(var.tags, { Name = "${var.prefix}-cluster" })
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight            = default_capacity_provider_strategy.value.weight
      base              = default_capacity_provider_strategy.value.base
    }
  }
}

###############################################################################
# CloudWatch Log Group for ECS tasks
###############################################################################
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.prefix}/${var.service_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

###############################################################################
# ECS Task Definition
###############################################################################
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.prefix}-${var.service_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    merge(
      {
        name      = var.container_name
        image     = var.container_image
        essential = true

        portMappings = [{
          containerPort = var.container_port
          protocol      = "tcp"
        }]

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.this.name
            awslogs-region        = var.aws_region
            awslogs-stream-prefix = "ecs"
          }
        }

        environment = [for k, v in var.environment_variables : { name = k, value = v }]

        secrets = [for k, v in var.secrets : { name = k, valueFrom = v }]

        readonlyRootFilesystem = var.readonly_root_filesystem
      },
      # Merge any extra container-level overrides provided by the caller
      var.container_definition_overrides
    )
  ])

  tags = merge(var.tags, { Name = "${var.prefix}-${var.service_name}" })
}

###############################################################################
# ECS Service
###############################################################################
resource "aws_ecs_service" "this" {
  name                               = "${var.prefix}-${var.service_name}"
  cluster                            = aws_ecs_cluster.this.id
  task_definition                    = aws_ecs_task_definition.this.arn
  desired_count                      = var.desired_count
  enable_execute_command             = var.enable_execute_command
  force_new_deployment               = var.force_new_deployment
  health_check_grace_period_seconds  = var.health_check_grace_period

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = var.target_group_arn != null ? [1] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.service_capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = capacity_provider_strategy.value.base
    }
  }

  tags = merge(var.tags, { Name = "${var.prefix}-${var.service_name}" })

  lifecycle {
    ignore_changes = [desired_count] # Managed by auto scaling
  }
}

###############################################################################
# ECS Service Auto Scaling
###############################################################################
resource "aws_appautoscaling_target" "this" {
  count = var.enable_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${var.prefix}-${var.service_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.autoscaling_cpu_target
    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
  }
}

resource "aws_appautoscaling_policy" "memory" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${var.prefix}-${var.service_name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.autoscaling_memory_target
    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
  }
}
