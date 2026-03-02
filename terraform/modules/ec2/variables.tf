variable "prefix" {
  type        = string
  description = "Prefix for resource naming"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where instances will be created"
  default     = null
}

variable "instances" {
  type = map(object({
    ami_id              = optional(string, "ami-0c55b159cbfafe1f0")
    instance_type       = optional(string, "t2.micro")
    subnet_id           = string
    security_groups     = optional(list(string), [])
    associate_public_ip = optional(bool, false)
    root_volume_size    = optional(number, 8)
    root_volume_type    = optional(string, "gp3")
    user_data_path      = optional(string, null)
    tags                = optional(map(string), {})
  }))
  description = "Map of instance configurations"
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Common tags for all instances"
}
