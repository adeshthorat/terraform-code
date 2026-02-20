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

# Task 1: EC2 instance - t2.micro with public IP


# Task 2: Add port 8000 inbound rule to existing SG
resource "aws_security_group_rule" "custom_tcp_8000" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "sg-0399c817d0c7de4b8"
}

#Task 3: Add Port 8080 inbound rule to existing SG
resource "aws_security_group_rule" "custom_tcp_8080" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "sg-09695058ea3c052ad"
}

#Task 5: Create s3 private bucket 
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "cops-artifact-bucket-"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}