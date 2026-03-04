variable "project_name" {
  description = "Name of the CodeBuild project."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{2,255}$", var.project_name))
    error_message = "project_name must be 2-255 characters: letters, numbers, underscores, and hyphens."
  }
}

variable "description" {
  description = "Human-readable description of the CodeBuild project."
  type        = string
  default     = "Managed by Terraform"
}

variable "service_role_arn" {
  description = "ARN of the IAM service role for CodeBuild."
  type        = string
}

variable "build_timeout_minutes" {
  description = "Maximum build duration in minutes (5–480)."
  type        = number
  default     = 30

  validation {
    condition     = var.build_timeout_minutes >= 5 && var.build_timeout_minutes <= 480
    error_message = "build_timeout_minutes must be between 5 and 480."
  }
}

###############################################################################
# Source
###############################################################################
variable "source_type" {
  description = "Source provider: GITHUB, CODECOMMIT, BITBUCKET, S3, CODEPIPELINE, or NO_SOURCE."
  type        = string
  default     = "CODEPIPELINE"

  validation {
    condition     = contains(["GITHUB", "CODECOMMIT", "BITBUCKET", "S3", "CODEPIPELINE", "NO_SOURCE"], var.source_type)
    error_message = "source_type must be a valid CodeBuild source type."
  }
}

variable "source_location" {
  description = "Source URL or S3 path. Not required when source_type=CODEPIPELINE."
  type        = string
  default     = null
}

variable "buildspec_inline" {
  description = "Inline buildspec YAML content as a string. Takes precedence over buildspec_file."
  type        = string
  default     = null
}

variable "buildspec_file" {
  description = "Path to the buildspec file relative to the source root (e.g. 'buildspec.yml'). Used when buildspec_inline is null."
  type        = string
  default     = null
}

variable "git_clone_depth" {
  description = "Git clone depth for GitHub/CodeCommit sources. 1 = shallow clone (faster)."
  type        = number
  default     = 1
}

variable "github_oauth_token" {
  description = "OAuth token ARN in Secrets Manager for GitHub source authentication."
  type        = string
  default     = null
}

###############################################################################
# Artifacts
###############################################################################
variable "artifacts_type" {
  description = "Artifact output type: CODEPIPELINE, S3, or NO_ARTIFACTS."
  type        = string
  default     = "CODEPIPELINE"

  validation {
    condition     = contains(["CODEPIPELINE", "S3", "NO_ARTIFACTS"], var.artifacts_type)
    error_message = "artifacts_type must be CODEPIPELINE, S3, or NO_ARTIFACTS."
  }
}

variable "artifacts_bucket" {
  description = "S3 bucket for build artifacts. Required when artifacts_type=S3."
  type        = string
  default     = null
}

variable "artifacts_path" {
  description = "S3 path prefix for artifacts."
  type        = string
  default     = "/"
}

variable "artifacts_name" {
  description = "Build artifact name inside the S3 bucket."
  type        = string
  default     = "build-output"
}

variable "artifacts_packaging" {
  description = "S3 artifact packaging: NONE or ZIP."
  type        = string
  default     = "ZIP"
}

###############################################################################
# Environment
###############################################################################
variable "compute_type" {
  description = "Build environment compute type."
  type        = string
  default     = "BUILD_GENERAL1_SMALL"

  validation {
    condition = contains([
      "BUILD_GENERAL1_SMALL", "BUILD_GENERAL1_MEDIUM", "BUILD_GENERAL1_LARGE",
      "BUILD_GENERAL1_2XLARGE", "BUILD_LAMBDA_1GB", "BUILD_LAMBDA_2GB",
      "BUILD_LAMBDA_4GB", "BUILD_LAMBDA_8GB", "BUILD_LAMBDA_10GB"
    ], var.compute_type)
    error_message = "compute_type must be a valid CodeBuild compute type."
  }
}

variable "build_image" {
  description = "Docker image for the build environment (e.g. aws/codebuild/standard:7.0)."
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "environment_type" {
  description = "CodeBuild environment type (LINUX_CONTAINER, LINUX_GPU_CONTAINER, ARM_CONTAINER, etc.)."
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "build_image_pull_credentials_type" {
  description = "Credentials used to pull the build image: CODEBUILD (default) or SERVICE_ROLE (for custom ECR images)."
  type        = string
  default     = "CODEBUILD"

  validation {
    condition     = contains(["CODEBUILD", "SERVICE_ROLE"], var.build_image_pull_credentials_type)
    error_message = "build_image_pull_credentials_type must be CODEBUILD or SERVICE_ROLE."
  }
}

variable "privileged_mode" {
  description = "Enable Docker daemon inside the build container. Required for 'docker build' commands."
  type        = bool
  default     = false
}

variable "environment_variables" {
  description = "Map of PLAINTEXT environment variable name => value injected into the build."
  type        = map(string)
  default     = {}
}

variable "secret_environment_variables" {
  description = "Map of environment variable name => Secrets Manager secret ARN (injected as SECRETS_MANAGER type)."
  type        = map(string)
  default     = {}
}

###############################################################################
# Logging
###############################################################################
variable "log_retention_days" {
  description = "Number of days to retain CodeBuild logs in CloudWatch."
  type        = number
  default     = 90
}

variable "enable_s3_log" {
  description = "Whether to also ship build logs to an S3 bucket."
  type        = bool
  default     = false
}

variable "s3_log_bucket" {
  description = "S3 bucket name for build logs. Required when enable_s3_log=true."
  type        = string
  default     = null
}

###############################################################################
# Cache
###############################################################################
variable "enable_s3_cache" {
  description = "Whether to create and use an S3 bucket for build caching (recommended for dependency caches)."
  type        = bool
  default     = false
}

variable "enable_local_cache" {
  description = "Whether to use local build cache (ephemeral — faster but lost between build hosts)."
  type        = bool
  default     = false
}

variable "local_cache_modes" {
  description = "Local cache modes when enable_local_cache=true: LOCAL_SOURCE_CACHE, LOCAL_DOCKER_LAYER_CACHE, LOCAL_CUSTOM_CACHE."
  type        = list(string)
  default     = ["LOCAL_SOURCE_CACHE"]
}

###############################################################################
# VPC
###############################################################################
variable "vpc_id" {
  description = "VPC ID if the build should run inside a VPC (e.g. to access private resources). Null = no VPC."
  type        = string
  default     = null
}

variable "vpc_subnet_ids" {
  description = "Subnet IDs for the build environment inside the VPC."
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Security group IDs for the build environment inside the VPC."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Map of tags applied to all CodeBuild resources."
  type        = map(string)
  default     = {}
}
