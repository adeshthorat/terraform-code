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
  source   = "../modules/vpc"
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
  id = "sg-09842d87b90b84e4b" # Replace with your SG ID
}


resource "aws_security_group_rule" "allow_BUAppServerAccess" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  security_group_id = data.aws_security_group.existing_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

#Date-2024-06-01 Task1: Add an egress rule to allow outbound traffic on port 1443 (HTTP) to the existing security group.
data "aws_security_group" "DB_access_sg" {
  id = "sg-00e55b130cd9713e1" # Replace with your SG ID
}

resource "aws_security_group_rule" "allow_DBServerAccess" {
  type              = "ingress"
  from_port         = 1443
  to_port           = 1443
  protocol          = "tcp"
  security_group_id = data.aws_security_group.DB_access_sg.id
  cidr_blocks       = ["10.0.0.0/8"]
  description       = "Allow outbound traffic on port 1443 (HTTP)"
}

resource "aws_security_group_rule" "allow_BastionAccess" {
  type              = "ingress"
  from_port         = 8001
  to_port           = 8001
  protocol          = "tcp"
  security_group_id = data.aws_security_group.DB_access_sg.id
  cidr_blocks       = ["10.0.0.0/8"]
  description       = "Allow inbound Bastion access for Port 8001 (HTTP)"
}

module "ecs_service" {
  source = "../modules/ecs/service"

  name        = "pyapp-test-cluster"
  cluster_arn = "arn:aws:ecs:us-east-1:536197253951:cluster/pyapp-test-cluster"

  cpu    = 1024
  memory = 4096

  # Container definition(s)
  container_definitions = {
    ecs-sample = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "536197253951.dkr.ecr.us-east-1.amazonaws.com/pyapp:green"
      portMappings = [
        {
          name          = "ecs-sample"
          containerPort = 5000
          protocol      = "tcp"
        }
      ]

      # Example image used requires access to write to root filesystem

      enable_cloudwatch_logging = false
      memoryReservation         = 100

      restartPolicy = {
        enabled              = true
        ignoredExitCodes     = [1]
        restartAttemptPeriod = 60
      }
    }
  }

  subnet_ids = ["subnet-0a267a31e408e9bc8", "subnet-0bec054e3c382b955", "subnet-09089e3303ff52b3c"]
  security_group_ingress_rules = {
    alb_3000 = {
      description = "Service port"
      from_port   = 5000
      ip_protocol = "tcp"
      to_port     = 5000
      cidr_ipv4   = "10.0.0.0/8"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
