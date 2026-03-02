resource "aws_instance" "this" {
  for_each = var.instances

  ami                         = each.value.ami_id
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = each.value.security_groups
  associate_public_ip_address = each.value.associate_public_ip
  user_data                   = each.value.user_data_path != null ? file(each.value.user_data_path) : null

  root_block_device {
    volume_size = each.value.root_volume_size
    volume_type = each.value.root_volume_type
  }

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name = "${var.prefix}-${each.key}-instance"
    }
  )
}

output "instance_ids" {
  value = { for k, v in aws_instance.this : k => v.id }
}

output "public_ips" {
  value = { for k, v in aws_instance.this : k => v.public_ip }
}
