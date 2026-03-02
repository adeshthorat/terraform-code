resource "aws_security_group" "this" {
  for_each    = var.security_groups
  name        = "${var.prefix}-${each.key}-sg"
  description = each.value.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress_rules
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
      self            = ingress.value.self
      description     = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = each.value.egress_rules
    content {
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
      self            = egress.value.self
      description     = egress.value.description
    }
  }

  tags = merge(var.common_tags, each.value.tags, {
    Name = "${var.prefix}-${each.key}-sg"
  })
}

output "security_group_ids" {
  value = { for k, v in aws_security_group.this : k => v.id }
}
