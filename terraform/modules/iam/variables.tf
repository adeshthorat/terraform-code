variable "prefix" {
  description = "Naming prefix applied to all IAM resources (e.g. 'myapp-prod')."
  type        = string
}

variable "tags" {
  description = "Map of tags applied to all IAM resources."
  type        = map(string)
  default     = {}
}

###############################################################################
# ECS Task Execution Role
###############################################################################
variable "create_ecs_task_execution_role" {
  description = "Whether to create the ECS Task Execution Role."
  type        = bool
  default     = true
}

variable "ecs_task_execution_extra_policies" {
  description = "Additional IAM policy statements to attach to the ECS Task Execution Role (e.g., to read Secrets Manager)."
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = string
  }))
  default = []
}

###############################################################################
# ECS Task Role
###############################################################################
variable "create_ecs_task_role" {
  description = "Whether to create the ECS Task Role (application-level permissions)."
  type        = bool
  default     = true
}

variable "ecs_task_inline_policies" {
  description = "IAM policy statements for the ECS Task Role."
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = string
  }))
  default = []
}

###############################################################################
# EC2 Instance Role
###############################################################################
variable "create_ec2_role" {
  description = "Whether to create an EC2 Instance Role and Instance Profile."
  type        = bool
  default     = false
}

###############################################################################
# Lambda Execution Role
###############################################################################
variable "create_lambda_role" {
  description = "Whether to create a Lambda Execution Role."
  type        = bool
  default     = false
}

variable "lambda_enable_vpc" {
  description = "Attach AWSLambdaVPCAccessExecutionRole if Lambda runs inside a VPC."
  type        = bool
  default     = false
}

variable "lambda_inline_policies" {
  description = "Extra IAM policy statements for the Lambda Role (e.g. DynamoDB, S3)."
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = string
  }))
  default = []
}

###############################################################################
# CodeBuild Role
###############################################################################
variable "create_codebuild_role" {
  description = "Whether to create a CodeBuild Service Role."
  type        = bool
  default     = false
}

variable "codebuild_extra_policies" {
  description = "Additional IAM policy statements for the CodeBuild Role."
  type        = list(any)
  default     = []
}

###############################################################################
# GitHub Actions OIDC Role
###############################################################################
variable "create_github_actions_role" {
  description = "Whether to create the GitHub Actions OIDC role and OIDC provider."
  type        = bool
  default     = false
}

variable "github_repo" {
  description = "GitHub repository in 'owner/repo' format (e.g. 'myorg/myrepo'). Required when create_github_actions_role=true."
  type        = string
  default     = ""
}

variable "github_branch" {
  description = "Branch allowed to assume the GitHub Actions role (e.g. 'main'). Required when create_github_actions_role=true."
  type        = string
  default     = "main"
}

variable "github_actions_policies" {
  description = "IAM policy statements granted to the GitHub Actions role."
  type        = list(any)
  default     = []
}
