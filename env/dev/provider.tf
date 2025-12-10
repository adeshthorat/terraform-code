terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.8.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "terraform-user-statefile-artifacts"
    key    = "tfstate/terraform.tfstate"
    region = "us-east-1"
  }
}
