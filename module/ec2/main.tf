resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [data.aws_security_group.example_sg.id] #Default Security Group will be attached if not mentioned
  root_block_device {
    volume_type = var.root_block_device.volume_type
    volume_size = var.root_block_device.volume_size
    encrypted   = var.root_block_device.encrypted
    kms_key_id  = var.root_block_device.kms_key_id
  }

  ebs_block_device {
    volume_type = var.ebs_block_device.volume_type
    volume_size = var.ebs_block_device.volume_size
    encrypted   = var.ebs_block_device.encrypted
    kms_key_id  = var.ebs_block_device.kms_key_id
    device_name = var.ebs_block_device.device_name
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      tags
    ]
  }
  tags = {
    Name        = "AWSUSAPP0912"
    created_by  = local.created_by
    Availabilty = local.Availabilty
  }
}

data "aws_vpc" "select" {
  default = true
}

data "aws_security_group" "example_sg" {
  # You can identify the security group by its name, ID, or a combination of filters.
  name   = "default"
  vpc_id = data.aws_vpc.select.id
}

locals {
  Team        = "Dev"
  Availabilty = "24*7"
  created_by  = "Terraform-Admin"
}




