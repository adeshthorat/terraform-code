terraform {
  backend "s3" {
    bucket       = "terraform-aws-tfstate5361"
    key          = "tfstate/terraform.tfstat"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../modules/vpc"
  name   = var.project_name
}

module "security_groups" {
  source = "../modules/security_groups"
  vpc_id = module.vpc.vpc_id
  prefix = var.project_name

  security_groups = {
    alb = {
      description = "Allow inbound HTTP/HTTPS to ALB"
      ingress_rules = [
        { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
        { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
      ]
    }
    app = {
      description = "Allow traffic from ALB to App"
      ingress_rules = [
        { from_port = 8080, to_port = 8080, protocol = "tcp", source_security_group_key = "alb" }
      ]
    }
    ecs = {
      description = "ECS tasks security group"
      ingress_rules = [
        { from_port = 8080, to_port = 8080, protocol = "tcp", self = true }
      ]
    }
  }
}

module "iam" {
  source                = "../modules/iam"
  prefix                = var.project_name
  github_repo           = "adeshthorat/terraform-code"
  create_lambda_role    = true
  create_codebuild_role = true
}

module "s3" {
  source      = "../modules/s3"
  common_tags = { Environment = "dev" }
  buckets = {
    app_data = {
      bucket_name        = "${var.project_name}-app-data-5361"
      versioning_enabled = true
    }
  }
}




