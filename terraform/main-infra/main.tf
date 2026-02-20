terraform {
  backend "s3" {
    bucket         = "terraform-aws-tfstate5361" # Replace with your bucket name
    key            = "tfstate/terraform.tfstate" # Replace with your state file path
    region         = "us-east-1"                 # Replace with your AWS region
    use_lockfile   = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../modules/vpc"
  vpc_name = "${var.project_name}-vpc"
}

module "security_groups" {
  source = "../modules/security_groups"
  vpc_id = module.vpc.vpc_id
  prefix = var.project_name
}


module "iam" {
  source      = "../modules/iam"
  prefix      = var.project_name
  github_repo = "adeshthorat/terraform-code"
}

#Task 1: Create an EC2 instance in the public subnet of the VPC with a security group that allows SSH access from anywhere. Use the latest Amazon Linux 2 AMI and a t2.micro instance type.
module "ec2"{
  source = "../modules/ec2"
  ami_id = "ami-0b6c6ebed2801a5cb" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  prefix = var.project_name
  instance_type = "t2.micro"
  subnet_id = "subnet-094c1647789b2b101"
  security_groups = ["sg-0854e3a19660651bd"]
  associate_public_ip = true
}
