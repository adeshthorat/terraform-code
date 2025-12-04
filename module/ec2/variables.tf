variable "name" {
  description = "Unique name for this EC2 instance"
  type        = string
}

variable "name_prefix" {
  description = "Project or environment prefix"
  type        = string
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Invalid instance type passed."
  }
}

variable "subnet_id" {
  type = string
}

variable "sg_ids" {
  type = list(string)
}

variable "iam_instance_profile" {
  type    = string
  default = null
}

variable "key_name" {
  type    = string
  default = null
}

variable "root_volume_size" {
  type    = number
  default = 20
}

variable "root_volume_type" {
  type    = string
  default = "gp3"
}

variable "additional_ebs_volumes" {
  type = map(object({
    device_name = string
    volume_size = number
    volume_type = string
  }))
  default = {}
}

variable "user_data" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
