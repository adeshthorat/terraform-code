variable "vpc_id" {
  type = string
}

variable "prefix" {
  type = string
}

variable "container_port" {
  type    = number
  default = 80
}
