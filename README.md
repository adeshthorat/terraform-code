# AWS Infrastructure — Terraform Modules

Production-grade, reusable Terraform modules for core AWS services. Each module follows a consistent 4-file structure (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`), enforces security best practices by default, and requires only the **essential** inputs — everything else has a sensible default.

---

## Modules

| Module | Description | Required Inputs |
|--------|-------------|-----------------|
| [`vpc`](./terraform/modules/vpc) | Multi-AZ VPC with public/private subnets, NAT Gateways, and VPC Flow Logs | `name` |
| [`security_groups`](./terraform/modules/security_groups) | Dynamic security groups with ingress/egress rule maps | `vpc_id`, `prefix` |
| [`iam`](./terraform/modules/iam) | Least-privilege IAM roles for ECS, EC2, Lambda, CodeBuild & GitHub OIDC | `prefix` |
| [`s3`](./terraform/modules/s3) | S3 buckets with encryption, versioning, access logging & lifecycle rules | `buckets` map |
| [`ecr`](./terraform/modules/ecr) | ECR repository with immutable tags, scan-on-push & lifecycle policy | `repository_name` |
| [`alb`](./terraform/modules/alb) | Application Load Balancer with HTTPS, HTTP→HTTPS redirect & deletion protection | `prefix`, `vpc_id`, `subnet_ids`, `security_group_ids` |
| [`ec2`](./terraform/modules/ec2) | EC2 instances with IMDSv2 enforcement & encrypted EBS volumes | `prefix`, `instances` map |
| [`asg`](./terraform/modules/asg) | Auto Scaling Group with rolling instance refresh & target tracking policies | `prefix`, `ami_id`, `subnet_ids`, `security_group_ids` |
| [`ecs`](./terraform/modules/ecs) | ECS cluster + Fargate service with Container Insights, circuit breaker & App Auto Scaling | `prefix`, `execution_role_arn`, `container_image`, `subnet_ids`, `security_group_ids` |
| [`lambda`](./terraform/modules/lambda) | Lambda function with CloudWatch logs, DLQ, X-Ray tracing & VPC support | `function_name`, `execution_role_arn` |
| [`codebuild`](./terraform/modules/codebuild) | CodeBuild project with CloudWatch logs, S3 cache, VPC support & secret env vars | `project_name`, `service_role_arn` |

---

## Security Standards Applied

| Practice | Details |
|----------|---------|
| **IMDSv2 enforced** | All EC2 instances and ASG launch templates require token-based metadata requests |
| **EBS encryption** | Root volumes encrypted by default (AWS-managed key; KMS opt-in) |
| **S3 public access blocked** | All four public-access-block settings are `true` on every bucket |
| **S3 encryption** | AES256 by default; KMS opt-in per bucket |
| **ECR immutable tags** | `IMMUTABLE` tag mutability prevents overwriting published image digests |
| **ECR scan on push** | Image vulnerability scanning enabled on every push |
| **ALB deletion protection** | ALB cannot be accidentally deleted |
| **ALB header hardening** | `drop_invalid_header_fields = true` mitigates HTTP desync attacks |
| **ALB TLS policy** | `ELBSecurityPolicy-TLS13-1-2-2021-06` — TLS 1.3 preferred |
| **VPC Flow Logs** | Enabled by default, 90-day CloudWatch retention |
| **ECS circuit breaker** | Automatic rollback on deployment failure |
| **Lambda X-Ray** | Active tracing enabled by default |
| **Lambda DLQ** | SQS Dead Letter Queue on every async function by default |
| **GitHub OIDC** | Branch-scoped conditions — no wildcard `*` on subject |
| **IAM least privilege** | Managed policies scoped per service; no `AdministratorAccess` |
| **Terraform version lock** | `required_version = ">= 1.5.0"`, AWS provider `>= 5.0.0` |

---

## Getting Started

### Prerequisites
- Terraform ≥ 1.5.0
- AWS credentials configured (`aws configure` or environment variables)
- Remote state backend (see [`terraform/bootstrap/`](./terraform/bootstrap/))

### Bootstrap (first-time setup)

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

This creates the S3 backend bucket and DynamoDB lock table used by `main-infra`.

### Deploy Infrastructure

```bash
cd terraform/main-infra
terraform init -backend-config="bucket=<your-state-bucket>" \
               -backend-config="key=main-infra/terraform.tfstate" \
               -backend-config="region=us-east-1"
terraform plan
terraform apply
```

---

## Module Usage Examples

### VPC

```hcl
module "vpc" {
  source = "./terraform/modules/vpc"

  name                 = "myapp-prod"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false # HA: one NAT per AZ
  enable_flow_logs   = true

  tags = { Environment = "prod", Team = "platform" }
}
```

### ECS (Fargate + Auto Scaling)

```hcl
module "ecs" {
  source = "./terraform/modules/ecs"

  prefix             = "myapp-prod"
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
  container_image    = "${module.ecr.repository_url}:v1.2.3"
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.security_group_ids["ecs"]]
  target_group_arn   = module.alb.target_group_arn

  task_cpu               = 512
  task_memory            = 1024
  desired_count          = 2
  enable_autoscaling     = true
  autoscaling_cpu_target = 60

  tags = { Environment = "prod" }
}
```

### Lambda

```hcl
module "api_lambda" {
  source = "./terraform/modules/lambda"

  function_name      = "myapp-prod-api"
  execution_role_arn = module.iam.lambda_role_arn
  runtime            = "python3.12"
  handler            = "app.handler"
  source_type        = "zip"
  source_path        = "${path.module}/dist/api.zip"

  environment_variables = {
    LOG_LEVEL = "INFO"
    STAGE     = "prod"
  }

  enable_xray_tracing = true
  enable_dlq          = true
  timeout             = 30
  memory_size         = 256

  tags = { Environment = "prod" }
}
```

### CodeBuild

```hcl
module "build" {
  source = "./terraform/modules/codebuild"

  project_name     = "myapp-prod-build"
  service_role_arn = module.iam.codebuild_role_arn
  source_type      = "GITHUB"
  source_location  = "https://github.com/myorg/myapp"

  environment_variables = {
    ECR_REPO_URI = module.ecr.repository_url
  }

  privileged_mode  = true  # required for docker builds
  enable_s3_cache  = true

  tags = { Environment = "prod" }
}
```

---

## Repository Structure

```
terraform/
├── bootstrap/          # Remote state infrastructure (S3 + DynamoDB)
├── main-infra/         # Root module — wires all modules together
└── modules/
    ├── vpc/            # VPC, subnets, NAT, flow logs
    ├── security_groups/ # Dynamic security group factory
    ├── iam/            # IAM roles (ECS, EC2, Lambda, CodeBuild, GitHub OIDC)
    ├── s3/             # S3 buckets with encryption & lifecycle
    ├── ecr/            # ECR repository with lifecycle policy
    ├── alb/            # Application Load Balancer + target group
    ├── ec2/            # EC2 instances (IMDSv2 + encrypted EBS)
    ├── asg/            # Auto Scaling Group + launch template
    ├── ecs/            # ECS cluster + Fargate service + App Auto Scaling
    ├── lambda/         # Lambda function + DLQ + X-Ray
    └── codebuild/      # CodeBuild project + cache + logging
```

---

## CI/CD (GitHub Actions)

| Workflow | Trigger | Action |
|----------|---------|--------|
| `terraform-plan.yml` | Pull Request to `main` | `terraform plan` — posts diff as PR comment |
| `terraform-apply.yml` | Push to `main` | `terraform apply -auto-approve` |
| `terraform-destroy.yml` | Manual (`workflow_dispatch`) | `terraform destroy` |

See [`.github/workflows/`](./.github/workflows/) for full configuration.

---

## Validation

```bash
# Validate all modules (run from repo root, requires terraform in PATH)
Get-ChildItem -Path "terraform/modules" -Directory | ForEach-Object {
  Write-Host "==> $($_.Name)"
  Push-Location $_.FullName
  terraform init -backend=false -input=false | Out-Null
  terraform validate
  Pop-Location
}
```
