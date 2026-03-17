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

  name                 = "dev-vpc"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true # HA: one NAT per AZ
  enable_flow_logs   = true

  tags = { Environment = "prod", Team = "platform" , ManagedBy = "Terraform" }
}


module "s3bucket" {
  source = "../modules/s3"
  bucket1{
    bucket_name = "my-unique-bucket-name-536197253951" # Must be globally unique
    versioning_enabled = true
    force_destroy = false
    kms_key_arn = null
    access_log_bucket = null
    tags = {
      Environment = "prod"
      Team        = "platform"
      ManagedBy   = "Terraform"
    }
    lifecycle_rules = [
      {
        id      = "transition-to-glacier"
        enabled = true
        transitions = [
          {
            days          = 30
            storage_class = "GLACIER"
          }
        ]
        expiration_days = 365
      }
    ]
  }
}