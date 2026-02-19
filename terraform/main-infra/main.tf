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

# Note: EKS is commented out as it takes ~20 mins to deploy and incurs significant cost
# module "eks" {
#   source           = "../modules/eks"
#   prefix           = var.project_name
#   cluster_role_arn = module.iam.eks_cluster_role_arn
#   node_role_arn    = module.iam.eks_node_role_arn
#   subnet_ids       = module.vpc.private_subnets
# }
