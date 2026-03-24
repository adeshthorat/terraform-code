variable "prefix" {
  description = "Naming prefix applied to every instance Name tag (e.g. 'myapp-prod')."
  type        = string
}

variable "common_tags" {
  description = "Tags applied to every EC2 instance in addition to per-instance tags."
  type        = map(string)
  default     = {}
}

variable "instances" {
  description = <<-EOT
    Map of EC2 instance configurations. Key = logical instance name.

    - ami_id                   (required) — AMI ID (e.g. ami-0abcdef1234567890).
    - instance_type            (required) — EC2 instance type (e.g. t3.medium).
    - subnet_id                (required) — Subnet ID to launch the instance in.
    - security_group_ids       (required) — List of security group IDs.
    - instance_profile_name    (optional) — IAM Instance Profile name. Recommended for SSM access.
    - key_name                 (optional) — EC2 key pair name. Prefer SSM Session Manager over SSH.
    - user_data                (optional) — Shell script as a string (not a file path).
    - root_volume_size_gb      (optional, default 20) — Root EBS volume size in GiB.
    - root_volume_type         (optional, default gp3) — Root EBS volume type.
    - kms_key_id               (optional) — KMS Key ID/ARN for root EBS encryption.
    - enable_detailed_monitoring (optional, default false) — Enable 1-minute CloudWatch metrics.
    - tags                     (optional, default {}) — Per-instance tags.
  EOT

  type = map(object({
    ami_id                     = string
    instance_type              = string
    subnet_id                  = string
    security_group_ids         = list(string)
    instance_profile_name      = optional(string, null)
    key_name                   = optional(string, null)
    associate_public_ip_address= optional(bool, false)
    user_data                  = optional(string, null)
    root_volume_size_gb        = optional(number, 20)
    root_volume_type           = optional(string, "gp3")
    kms_key_id                 = optional(string, null)
    enable_detailed_monitoring = optional(bool, false)
    tags                       = optional(map(string), {})
  }))

  default = {}
}
