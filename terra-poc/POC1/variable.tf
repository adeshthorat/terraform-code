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

variable "sg-ports" {
  description = "List of SG IDs to attach"
  type        = list(string)
  default     = ["80", "443"]
}
