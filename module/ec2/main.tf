resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.sg_ids
  iam_instance_profile = var.iam_instance_profile
  key_name             = var.key_name

  user_data = var.user_data != "" ? var.user_data : null

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = true
  }

  dynamic "ebs_block_device" {
    for_each = var.additional_ebs_volumes
    content {
      device_name = ebs_block_device.value.device_name
      volume_size = ebs_block_device.value.volume_size
      volume_type = ebs_block_device.value.volume_type
      encrypted   = true
    }
  }

  tags = merge(
    {
      Name = "${var.name_prefix}-${var.name}"
    },
    var.tags
  )
}
