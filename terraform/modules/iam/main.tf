###############################################################################
# IAM Module
#
# Creates least-privilege IAM roles for:
#   - ECS Task Execution (pull images, write logs)
#   - ECS Task (application-level permissions)
#   - EC2 Instance Profile (SSM + CloudWatch)
#   - Lambda Execution (logs + VPC)
#   - CodeBuild (S3 + ECR + logs)
#   - GitHub Actions OIDC (CI/CD deployments)
###############################################################################

###############################################################################
# Local: common assume-role policy fragments
###############################################################################
locals {
  ecs_tasks_principal  = { Service = "ecs-tasks.amazonaws.com" }
  ec2_principal        = { Service = "ec2.amazonaws.com" }
  lambda_principal     = { Service = "lambda.amazonaws.com" }
  codebuild_principal  = { Service = "codebuild.amazonaws.com" }
}

###############################################################################
# ECS Task Execution Role
# Allows ECS to pull images from ECR and write logs to CloudWatch.
###############################################################################
resource "aws_iam_role" "ecs_task_execution" {
  count = var.create_ecs_task_execution_role ? 1 : 0

  name        = "${var.prefix}-ecs-task-execution-role"
  description = "ECS Task Execution Role — grants ECS the right to pull ECR images and write CloudWatch Logs."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = local.ecs_tasks_principal
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  count = var.create_ecs_task_execution_role ? 1 : 0

  role       = aws_iam_role.ecs_task_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Optional: attach secrets manager read if the application reads SSM / Secrets Manager
resource "aws_iam_role_policy" "ecs_task_execution_extra" {
  count = var.create_ecs_task_execution_role && length(var.ecs_task_execution_extra_policies) > 0 ? 1 : 0

  name = "${var.prefix}-ecs-task-execution-extra"
  role = aws_iam_role.ecs_task_execution[0].id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.ecs_task_execution_extra_policies
  })
}

###############################################################################
# ECS Task Role
# Application-level role assumed by the running container.
###############################################################################
resource "aws_iam_role" "ecs_task" {
  count = var.create_ecs_task_role ? 1 : 0

  name        = "${var.prefix}-ecs-task-role"
  description = "ECS Task Role — application-level permissions assumed by the container process."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = local.ecs_tasks_principal
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "ecs_task_inline" {
  count = var.create_ecs_task_role && length(var.ecs_task_inline_policies) > 0 ? 1 : 0

  name = "${var.prefix}-ecs-task-inline"
  role = aws_iam_role.ecs_task[0].id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.ecs_task_inline_policies
  })
}

###############################################################################
# EC2 Instance Role + Instance Profile
# Grants EC2 access to Systems Manager & CloudWatch Agent — no SSH keys required.
###############################################################################
resource "aws_iam_role" "ec2" {
  count = var.create_ec2_role ? 1 : 0

  name        = "${var.prefix}-ec2-role"
  description = "EC2 Instance Role — SSM Session Manager and CloudWatch agent access."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = local.ec2_principal
    }]
  })
  

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  count = var.create_ec2_role ? 1 : 0

  role       = aws_iam_role.ec2[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "other_policy" {
  count = var.create_ec2_role ? 1 : 0

  role       = aws_iam_role.ec2[0].name
  policy_arn = var.ec2_extra_policy_arn
}

resource "aws_iam_instance_profile" "ec2" {
  count = var.create_ec2_role ? 1 : 0

  name = "${var.prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2[0].name

  tags = var.tags
}

###############################################################################
# Lambda Execution Role
###############################################################################
resource "aws_iam_role" "lambda" {
  count = var.create_lambda_role ? 1 : 0

  name        = "${var.prefix}-lambda-role"
  description = "Lambda Execution Role — CloudWatch Logs and optional VPC networking."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = local.lambda_principal
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  count = var.create_lambda_role ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Add VPC access if the Lambda runs inside a VPC
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count = var.create_lambda_role && var.lambda_enable_vpc ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_inline" {
  count = var.create_lambda_role && length(var.lambda_inline_policies) > 0 ? 1 : 0

  name = "${var.prefix}-lambda-inline"
  role = aws_iam_role.lambda[0].id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.lambda_inline_policies
  })
}

###############################################################################
# CodeBuild Role
###############################################################################
resource "aws_iam_role" "codebuild" {
  count = var.create_codebuild_role ? 1 : 0

  name        = "${var.prefix}-codebuild-role"
  description = "CodeBuild Service Role — S3, ECR, CloudWatch Logs, and VPC access."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = local.codebuild_principal
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "codebuild_inline" {
  count = var.create_codebuild_role ? 1 : 0

  name = "${var.prefix}-codebuild-policy"
  role = aws_iam_role.codebuild[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = "*"
      }
    ], var.codebuild_extra_policies)
  })
}

###############################################################################
# GitHub Actions OIDC Role
###############################################################################
resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_actions_role ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = var.tags
}

resource "aws_iam_role" "github_actions" {
  count = var.create_github_actions_role ? 1 : 0

  name        = "${var.prefix}-github-actions-role"
  description = "Assumed by GitHub Actions via OIDC — scoped to a specific repo and branch."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRoleWithWebIdentity"
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github[0].arn }
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:ref:refs/heads/${var.github_branch}"
        }
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "github_actions_inline" {
  count = var.create_github_actions_role && length(var.github_actions_policies) > 0 ? 1 : 0

  name = "${var.prefix}-github-actions-policy"
  role = aws_iam_role.github_actions[0].id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.github_actions_policies
  })
}
