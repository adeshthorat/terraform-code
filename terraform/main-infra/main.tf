terraform {
  backend "s3" {
    bucket       = "terraform-aws-tfstate5361" # Replace with your bucket name
    key          = "tfstate/terraform.tfstate" # Replace with your state file path
    region       = "us-east-1"                 # Replace with your AWS region
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../modules/vpc"

  name                 = "dev-vpc"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true # HA: one NAT per AZ
  enable_flow_logs   = false

  tags = { Environment = "prod", Team = "platform", ManagedBy = "Terraform" }
}


module "s3bucket" {
  source = "../modules/s3"

  buckets = {
    prod_bucket = {
      bucket_name        = "test-logs-bucket-536197253951"
      versioning_enabled = true
      force_destroy      = false
      kms_key_arn        = null
      access_log_bucket  = null

      tags = {
        Environment = "prod"
        Team        = "platform"
        ManagedBy   = "Terraform"
      }
    }
  }
}


module "security_groups" {
  source = "../modules/security_groups"
  prefix = "dev"
  vpc_id = module.vpc.vpc_id
  security_groups = {
    web = {
      description = "Web servers SG"
      ingress_rules = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow HTTP from anywhere"
        },
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow HTTPS from anywhere"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow all outbound"
        }
      ]
      tags = { Role = "webserver" }
    }
  }
}

module "iam" {
  source               = "../modules/iam"
  prefix               = "dev"
  create_ec2_role      = true
  ec2_extra_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # Example additional policy for EC2 Role
}



module "ec2" {
  source = "../modules/ec2"
  prefix = "app-server-1"

  instances = {
    web1 = {
      ami_id                      = "ami-0ec10929233384c7f" # Amazon Linux 2 AMI in us-east-1
      instance_type               = "t3.micro"
      subnet_id                   = module.vpc.public_subnet_ids[0]
      iam_instance_profile        = module.iam.ec2_instance_profile_name
      associate_public_ip_address = true
      security_group_ids          = [module.security_groups.security_group_ids["web"]]
      user_data                   = <<-EOF
        #!/bin/bash
        sudo apt update -y
        sudo apt install -y nginx
        sudo systemctl start nginx
        EOF
      key_name                    = null
      tags                        = { Name = "web1", Role = "webserver" }
    }
  }
}


module "alb-security_groups" {
  source = "../modules/security_groups"
  prefix = "dev"
  vpc_id = module.vpc.vpc_id
  security_groups = {
    lb = {
      description = "Web servers SG"
      ingress_rules = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow HTTP from anywhere"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow all outbound"
        }
      ]
      tags = { Role = "load-balancer-sg" }
    }
  }
}

