# AWS Infrastructure Management with Terraform & GitHub Actions

This repository contains production-grade Terraform configurations to provision and manage AWS resources including EC2, ECS, EKS, S3, VPC, ECR, ALB, and ASG.

## Getting Started

1. **Bootstrap**: Navigate to `terraform/bootstrap` and run `terraform init` and `terraform apply` to create the remote state S3 bucket and DynamoDB table.
2. **Configure GitHub Secrets**: Set up the following secrets in your GitHub repository:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `TF_STATE_BUCKET` (The name of the bucket created in step 1)
   - `TF_LOCK_TABLE` (The name of the DynamoDB table created in step 1)
3. **Provision Resources**: Push your changes to the `main` branch or create a pull request to trigger the GitHub Actions workflows.

## Directory Structure

- `terraform/modules/`: Reusable Terraform modules for each AWS resource.
- `terraform/main-infra/`: Root configuration to deploy the infrastructure.
- `terraform/bootstrap/`: Initial setup for remote state management.
- `.github/workflows/`: Automated CI/CD pipelines.
