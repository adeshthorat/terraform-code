resource "aws_launch_template" "this" {
  name_prefix   = "${var.prefix}-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_groups
  }

  tags = var.tags
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.prefix}-asg"
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  vpc_zone_identifier = var.private_subnets

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.prefix}-asg-instance"
    propagate_at_launch = true
  }
}
