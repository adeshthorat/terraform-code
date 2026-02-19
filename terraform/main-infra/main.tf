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

module "s3" {
  source      = "../modules/s3"
  bucket_name = "${var.project_name}-data-bucket"
}

module "ecr" {
  source    = "../modules/ecr"
  repo_name = "${var.project_name}-app"
}

module "alb" {
  source          = "../modules/alb"
  prefix          = var.project_name
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  security_groups = [module.security_groups.alb_sg_id]
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

module "ecs" {
  source              = "../modules/ecs"
  prefix              = var.project_name
  task_definition_arn = "arn:aws:ecs:us-east-1:123456789012:task-definition/sample-task:1" # Placeholder
  private_subnets     = module.vpc.private_subnets
  security_groups      = [module.security_groups.ecs_tasks_sg_id]
  target_group_arn    = module.alb.target_group_arn
  container_name      = "app"
}

module "asg" {
  source          = "../modules/asg"
  prefix          = var.project_name
  ami_id          = "ami-0c55b159cbfafe1f0"
  private_subnets = module.vpc.private_subnets
  security_groups = [module.security_groups.ecs_tasks_sg_id]
}

# Note: EKS is commented out as it takes ~20 mins to deploy and incurs significant cost
# module "eks" {
#   source           = "../modules/eks"
#   prefix           = var.project_name
#   cluster_role_arn = module.iam.eks_cluster_role_arn
#   node_role_arn    = module.iam.eks_node_role_arn
#   subnet_ids       = module.vpc.private_subnets
# }
