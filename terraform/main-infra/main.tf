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


module "s3bucket-17032026" {
  source = "../modules/s3"

  bucket_name = "test-logs-bucket-536197253951" # Replace with a unique bucket name
  versioning   = true
  tags        = { Environment = "prod", Team = "platform", ManagedBy = "Terraform" }
}