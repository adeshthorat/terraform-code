variable "sg_ids" {
  type    = list(string)
  default = []
}
variable "instance_type" {
  type = string
}
variable "ami" {
  type = string
}
variable "subnet_id" {
  type = string
}
