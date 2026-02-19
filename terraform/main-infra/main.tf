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

module "ec2" {
  source              = "../modules/ec2"
  prefix              = var.project_name
  instance_type       = "t2.small"
  associate_public_ip = true
  root_volume_size    = 8
  subnet_id           = module.vpc.public_subnets[0]
  security_groups     = [module.security_groups.alb_sg_id] # Reusing ALB SG for port 80 access
}

module "iam" {
  source      = "../modules/iam"
  prefix      = var.project_name
  github_repo = "adeshthorat/terraform-code"
}

# Note: EKS is commented out as it takes ~20 mins to deploy and incurs significant cost
# module "eks" {
#   source           = "../modules/eks"
#   prefix           = var.project_name
#   cluster_role_arn = module.iam.eks_cluster_role_arn
#   node_role_arn    = module.iam.eks_node_role_arn
#   subnet_ids       = module.vpc.private_subnets
# }
