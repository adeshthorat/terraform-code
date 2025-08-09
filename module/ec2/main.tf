resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_groups
  root_block_device {
    volume_type = var.root_block_device.volume_type
    volume_size = var.root_block_device.volume_size
    encrypted   = var.root_block_device.encrypted
    kms_key_id  = var.root_block_device.kms_key_id
  }
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags
    ]
  }

  tags = {
    Name     = "AWS${var.environment}${local.generate_id}"
    Team     = local.Team
    AppOwner = "adesh_thorat"
  }

}

locals {
  Team        = "${var.environment}-Team"
  created_on  = timestamp()
  generate_id = random_integer.server.id
  AppOwner    = "adesh_thorat"

}

resource "random_integer" "server" {
  min = 10000
  max = 99999
}
