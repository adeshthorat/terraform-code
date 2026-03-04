###############################################################################
# CodeBuild Module
#
# Creates:
#   - CodeBuild project with configurable source, environment, and artifacts
#   - CloudWatch Log Group with retention
#   - S3 cache bucket (optional)
#   - VPC configuration (optional)
#   - Secondary artifacts support (optional)
###############################################################################

###############################################################################
# CloudWatch Log Group
###############################################################################
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/codebuild/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

###############################################################################
# S3 Build Cache Bucket (optional)
###############################################################################
resource "aws_s3_bucket" "cache" {
  count = var.enable_s3_cache ? 1 : 0

  bucket        = "${var.project_name}-build-cache-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "cache" {
  count  = var.enable_s3_cache ? 1 : 0
  bucket = aws_s3_bucket.cache[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cache" {
  count  = var.enable_s3_cache ? 1 : 0
  bucket = aws_s3_bucket.cache[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_caller_identity" "current" {}

###############################################################################
# CodeBuild Project
###############################################################################
resource "aws_codebuild_project" "this" {
  name          = var.project_name
  description   = var.description
  service_role  = var.service_role_arn
  build_timeout = var.build_timeout_minutes

  # Source
  source {
    type            = var.source_type
    location        = var.source_location
    buildspec = coalesce(var.buildspec_inline, var.buildspec_file)
    git_clone_depth = var.source_type == "GITHUB" || var.source_type == "CODECOMMIT" ? var.git_clone_depth : null

    dynamic "auth" {
      for_each = var.source_type == "GITHUB" && var.github_oauth_token != null ? [1] : []
      content {
        type     = "OAUTH"
        resource = var.github_oauth_token
      }
    }
  }

  # Artifacts
  artifacts {
    type                = var.artifacts_type
    location            = var.artifacts_type == "S3" ? var.artifacts_bucket : null
    path                = var.artifacts_type == "S3" ? var.artifacts_path : null
    name                = var.artifacts_type == "S3" ? var.artifacts_name : null
    packaging           = var.artifacts_type == "S3" ? var.artifacts_packaging : null
    encryption_disabled = false
  }

  # Environment
  environment {
    compute_type                = var.compute_type
    image                       = var.build_image
    type                        = var.environment_type
    image_pull_credentials_type = var.build_image_pull_credentials_type
    privileged_mode             = var.privileged_mode # Required for Docker builds

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
        type  = "PLAINTEXT"
      }
    }

    dynamic "environment_variable" {
      for_each = var.secret_environment_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
        type  = "SECRETS_MANAGER"
      }
    }
  }

  # Logging
  logs_config {
    cloudwatch_logs {
      status     = "ENABLED"
      group_name = aws_cloudwatch_log_group.this.name
    }

    s3_logs {
      status              = var.enable_s3_log ? "ENABLED" : "DISABLED"
      location            = var.enable_s3_log ? "${var.s3_log_bucket}/${var.project_name}" : null
      encryption_disabled = false
    }
  }

  # Cache
  cache {
    type     = var.enable_s3_cache ? "S3" : (var.enable_local_cache ? "LOCAL" : "NO_CACHE")
    location = var.enable_s3_cache ? "${aws_s3_bucket.cache[0].id}/cache" : null
    modes    = var.enable_local_cache ? var.local_cache_modes : []
  }

  # Optional: VPC configuration
  dynamic "vpc_config" {
    for_each = var.vpc_id != null ? [1] : []
    content {
      vpc_id             = var.vpc_id
      subnets            = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  tags = var.tags
}
