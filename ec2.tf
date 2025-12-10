module "ec2_app" {
  source        = "../../module/ec2"
  name          = "app1"
  name_prefix   = "test"
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  sg_ids        = var.sg_ids
  user_data     = file("user-data.sh")
}
