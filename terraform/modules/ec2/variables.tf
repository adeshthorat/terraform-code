variable "prefix" {
  type = string
}

variable "ami_id" {
  type    = string
  default = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 in us-east-1
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "subnet_id" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "associate_public_ip" {
  type    = bool
  default = false
}

variable "root_volume_size" {
  type    = number
  default = 8
}

variable "root_volume_type" {
  type    = string
  default = "gp3"
}

variable "tags" {
  type    = map(string)
  default = {}
}
