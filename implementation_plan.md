# AWS Infrastructure with Terraform & GitHub Actions

Provision and manage core AWS resources (EC2, ECS, EKS, S3, VPC, ECR, ALB, ASG) using a modular Terraform approach with automated CI/CD via GitHub Actions.

## Proposed Changes

### Repository Structure
- `terraform/modules/`: Contains reusable modules for each AWS resource.
- `terraform/main-infra/`: Root configuration to deploy the infrastructure.
- `terraform/bootstrap/`: Initial setup for remote state (S3 & DynamoDB).
- `.github/workflows/`: GitHub Actions for Plan, Apply, and Destroy operations.

### Terraform Modules
- **VPC Module**: Multi-AZ VPC with Public and Private subnets, NAT Gateways, and IGW.
- **Security Groups**: Granular security groups for different service tiers.
- **Compute (EC2/ASG/ALB)**: Auto Scaling Group with Application Load Balancer.
- **Containerization (ECR/ECS/EKS)**: ECR repositories, ECS Clusters, and EKS Cluster setup.
- **Storage (S3)**: General-purpose S3 bucket management.

### CI/CD Workflow
- **Feature Branch**: Triggers `terraform plan` to preview changes in PRs.
- **Main Branch**: Merges trigger `terraform apply` to deploy changes.
- **Manual Trigger**: `terraform destroy` workflow for teardown when needed.

## Verification Plan

### Automated Tests
- Run `terraform validate` and `terraform plan` in GitHub Actions.
- Use `tflint` for linting and `terrascan` or `tfsec` for security scanning.

### Manual Verification
- Review the `terraform plan` output in GitHub PR comments.
- Verify resource creation in the AWS Console after deployment.
- Test connectivity and service health (e.g., ALB DNS, ECS Task status).
