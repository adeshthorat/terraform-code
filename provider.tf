terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.8"
    }
  }

  backend "s3" {
    bucket         = "terraform-user-statefile-artifacts"
    key            = "tfstate/terraform.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}
