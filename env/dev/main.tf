# This module creates an AWS Serve
module "aws_server" {
  source          = "./module/ec2"
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  security_groups = var.security_groups
  root_block_device = {
    volume_type = var.root_block_device.volume_type
    volume_size = var.root_block_device.volume_size
    encrypted   = var.root_block_device.encrypted
    kms_key_id  = var.root_block_device.kms_key_id
  }
}


locals {
  Team       = "${var.Environment}-Team"
  AppOwner   = ""
  created_on = timestamp()

}
