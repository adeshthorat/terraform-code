###############################################################################
# Auto Scaling Module (ASG + Launch Template)
#
# Production defaults:
#   - IMDSv2 enforced in launch template
#   - EBS encryption at rest
#   - IAM Instance Profile support
#   - Target Tracking scaling policy (CPU, request count, or custom)
#   - Health check grace period
#   - Deployment with instance refresh (rolling update)
###############################################################################

###############################################################################
# Launch Template
###############################################################################
resource "aws_launch_template" "this" {
  name_prefix   = "${var.prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = var.user_data != null ? base64encode(var.user_data) : null

  # IMDSv2 enforcement
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  network_interfaces {
    associate_public_ip_address = false # Launch into private subnets by default
    security_groups             = var.security_group_ids
    delete_on_termination       = true
  }

  dynamic "iam_instance_profile" {
    for_each = var.instance_profile_name != null ? [1] : []
    content {
      name = var.instance_profile_name
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size_gb
      volume_type           = var.root_volume_type
      encrypted             = true
      kms_key_id            = var.kms_key_id
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.prefix}-asg-instance" })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(var.tags, { Name = "${var.prefix}-asg-volume" })
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

###############################################################################
# Auto Scaling Group
###############################################################################
resource "aws_autoscaling_group" "this" {
  name                      = "${var.prefix}-asg"
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.target_group_arns
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  # Rolling update strategy — replaces instances without downtime
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = var.instance_refresh_min_healthy_percentage
      instance_warmup        = var.instance_refresh_warmup
    }
  }

  dynamic "tag" {
    for_each = merge(var.tags, { Name = "${var.prefix}-asg" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity] # Prevent Terraform from resetting after scaling
  }
}

###############################################################################
# Target Tracking Scaling Policy
###############################################################################
resource "aws_autoscaling_policy" "target_tracking_cpu" {
  count = var.enable_cpu_scaling_policy ? 1 : 0

  name                   = "${var.prefix}-cpu-scaling"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_scaling_target_value
  }
}

resource "aws_autoscaling_policy" "target_tracking_alb_requests" {
  count = var.enable_alb_request_scaling_policy && var.target_group_arn_suffix != null ? 1 : 0

  name                   = "${var.prefix}-alb-request-scaling"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${var.alb_arn_suffix}/${var.target_group_arn_suffix}"
    }
    target_value = var.alb_request_scaling_target_value
  }
}
