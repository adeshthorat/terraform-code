#==============VPC Variables====================

variable "cidr-range" {
  default = "10.0.0.0/16"
}

#==============EC2 Varibles ./module/ec2=====================
variable "ami_id" {
  description = "AMI ID to Create Server"
  type        = string

}
variable "security_groups" {
  type = list(string)
}

variable "subnet_id" {
  description = "Subnet id"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "root_block_device" {
  description = "Root block device configuration"
  type = object({
    volume_type = string
    volume_size = number
    encrypted   = bool
    kms_key_id  = string
  })
  default = {
    volume_type = "gp2"
    volume_size = 10
    encrypted   = false
    kms_key_id  = null
  }
}

variable "Environment" {
  description = "Resource will tagged as DEV"
  default     = "DEV"
}
