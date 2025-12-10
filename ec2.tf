module "ec2_app" {
  source        = "./module/ec2"
  name          = "US00123"
  name_prefix   = "AWSAPP"
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  sg_ids        = var.sg_ids
  user_data     = file("user-data.sh")
}
