# Terraform AWS Deployment

# Overview

This directory contains Terraform configuration files and a GitHub Actions workflow for deploying an AWS EC2 instance

# Files

- `terraform.tfvars`: Contains variable definitions for the Terraform configuration.
- `main.tf`: The main Terraform configuration file that defines the AWS EC2 instance.
- `module/ec2`: A module that encapsulates the EC2 instance configuration.
- `.github/workflows/tf-deploy.yml`: A GitHub Actions workflow that automates the deployment of the Terraform configuration.
  workflow will only run when there are changes to `terraform.tfvars`.

# Usage

1. **Set up your AWS credentials**: Ensure you have your AWS credentials configured in your
   environment or in the AWS CLI.

2. **Initialize Terraform**: Run `terraform init` in the directory containing `main.tf` to initialize the Terraform working directory.

3. **Apply the configuration**: Run `terraform apply` to create the resources defined in
   the Terraform configuration.
4. **GitHub Actions**: The workflow defined in `.github/workflows/tf-deploy.yml` will automatically run on pushes to the `main` branch, deploying the Terraform configuration if there are changes to `terraform.tfvars`.
