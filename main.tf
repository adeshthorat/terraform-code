# module "ec2-server" {
#   source = "./module/ec2"
# }

module "vpc-create" {
  source = "./module/vpc"
  cidr-range = "10.0.0.0/24"
}
