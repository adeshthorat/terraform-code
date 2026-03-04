###############################################################################
# EC2 Module
#
# Production defaults:
#   - IMDSv2 enforced (no IMDSv1 — mitigates SSRF metadata attacks)
#   - EBS root volume encrypted at rest
#   - IAM Instance Profile support
#   - Key pair optional (prefer SSM Session Manager)
#   - User-data support (passed as string, not file path)
###############################################################################

resource "aws_instance" "this" {
  for_each = var.instances

  ami                    = each.value.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.security_group_ids
  iam_instance_profile   = each.value.instance_profile_name
  key_name               = each.value.key_name
  user_data_base64       = each.value.user_data != null ? base64encode(each.value.user_data) : null

  # IMDSv2 enforcement — prevents SSRF-based credential theft
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"   # IMDSv2 only
    http_put_response_hop_limit = 1            # containers cannot reach IMDS
    instance_metadata_tags      = "enabled"
  }

  root_block_device {
    volume_size           = each.value.root_volume_size_gb
    volume_type           = each.value.root_volume_type
    encrypted             = true
    kms_key_id            = each.value.kms_key_id
    delete_on_termination = true
  }

  monitoring = each.value.enable_detailed_monitoring

  tags = merge(var.common_tags, each.value.tags, {
    Name = "${var.prefix}-${each.key}"
  })

  lifecycle {
    ignore_changes = [ami] # Prevent replacement on AMI updates; handle with new instance + drain
  }
}
