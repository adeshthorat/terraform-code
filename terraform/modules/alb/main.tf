###############################################################################
# ALB Module
#
# Production defaults:
#   - Deletion protection enabled
#   - Invalid header dropping enabled (OWASP hardening)
#   - HTTPS listener with ACM certificate (optional)
#   - HTTP → HTTPS redirect when HTTPS is enabled
#   - Access logging to S3 (optional)
#   - Configurable health check
###############################################################################

resource "aws_lb" "this" {
  name               = "${var.prefix}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = true # Mitigates HTTP desync attacks (OWASP)
  idle_timeout               = var.idle_timeout

  dynamic "access_logs" {
    for_each = var.access_logs_bucket != null ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(var.tags, { Name = "${var.prefix}-alb" })
}

###############################################################################
# Target Group
###############################################################################
resource "aws_lb_target_group" "this" {
  name        = "${var.prefix}-tg"
  port        = var.target_port
  protocol    = var.target_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  deregistration_delay = var.deregistration_delay

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = var.target_protocol
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
  }

  tags = merge(var.tags, { Name = "${var.prefix}-tg" })

  lifecycle {
    create_before_destroy = true
  }
}

###############################################################################
# HTTP Listener — either forward (HTTP-only) or redirect to HTTPS
###############################################################################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = var.enable_https ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.enable_https ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = var.enable_https ? [] : [1]
      content {
        target_group {
          arn = aws_lb_target_group.this.arn
        }
      }
    }
  }

  tags = var.tags
}

###############################################################################
# HTTPS Listener (optional)
###############################################################################
resource "aws_lb_listener" "https" {
  count = var.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = var.tags
}
