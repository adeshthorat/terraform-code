variable "instances" {
  description = "Map of instance name to EC2 type"
  type = map(object({
    instance_type = string
  }))
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "instance tags"
}

variable "tags-all" {
  type        = map(string)
  description = "Common tags for all"
}

variable "aws_vpc" {
  description = "Default VPC variable"
  type        = string
  default     = "true"
}

variable "subnet_id" {
  description = "Subnet where EC2 instances will run"
  type        = string
  default     = "true"
}

variable "aws_security_group" {
  description = "Default sg group"
  default     = ""
}

variable "availability_zone" {
  description = "ebs az"
  default     = "us-east-1a"
}

variable "sg-ports" {
  description = "List of SG IDs to attach"
  type        = list(string)
  default     = ["80", "443"]
}

variable "additional_ebs" {
  description = "Additional ebs volume"
  type = list(object({
    device_name = string
    volume_size = number
    volume_type = string
    iops        = optional(number)
    encrypted   = optional(bool, true)
  }))

  default = []
}

variable "create" {
  description = "Whether to create an instance"
  type        = bool
  default     = true
}
