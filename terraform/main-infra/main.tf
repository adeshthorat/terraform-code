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

data "aws_security_group" "existing_sg" {
  id = "sg-09842d87b90b84e4b"  # Replace with your SG ID
}


resource "aws_security_group_rule" "allow_BUAppServerAccess" {
  type            = "ingress"
  from_port       = 8000
  to_port         = 8000
  protocol        = "tcp"
  security_group_id = data.aws_security_group.existing_sg.id
  cidr_blocks     = ["0.0.0.0/0"]
}

#Date-2024-06-01 Task1: Add an egress rule to allow outbound traffic on port 1443 (HTTP) to the existing security group.
data "aws_security_group" "DB_access_sg" {
  id = "sg-00e55b130cd9713e1"  # Replace with your SG ID
}

resource "aws_security_group_rule" "allow_DBServerAccess" {
  type            = "ingress"
  from_port       = 1443
  to_port         = 1443
  protocol        = "tcp"
  security_group_id = data.aws_security_group.DB_access_sg.id
  cidr_blocks     = ["10.0.0.0/0"]
  description     = "Allow outbound traffic on port 1443 (HTTP)"
  tags ={
    Name = Allow_DB-Access
    modifiedBy = "AdeshThorat"
    Date = "2026-03-02"
  }
}