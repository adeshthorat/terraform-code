variable "prefix" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "security_groups" {
  type = list(string)
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "private_subnets" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
