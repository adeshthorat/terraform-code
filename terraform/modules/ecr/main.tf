###############################################################################
# ECR Module
#
# Production defaults:
#   - IMMUTABLE tags (prevents overwriting existing image tags)
#   - Image scanning on push
#   - KMS encryption optional (AES256 by default)
#   - Lifecycle policy to cap the number of stored images
#   - Optional cross-account repository policy
###############################################################################

resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = var.kms_key_arn != null ? "KMS" : "AES256"
    kms_key         = var.kms_key_arn
  }

  tags = merge(var.tags, { Name = var.repository_name })
}

###############################################################################
# Lifecycle Policy — keep only the last N untagged and tagged images
###############################################################################
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than ${var.untagged_image_expiry_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_expiry_days
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep only the last ${var.max_image_count} tagged images"
        selection = {
          tagStatus   = "tagged"
          tagPrefixList = var.lifecycle_tag_prefixes
          countType   = "imageCountMoreThan"
          countNumber = var.max_image_count
        }
        action = { type = "expire" }
      }
    ]
  })
}

###############################################################################
# Optional: Repository policy for cross-account access
###############################################################################
resource "aws_ecr_repository_policy" "this" {
  count = var.repository_policy_json != null ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = var.repository_policy_json
}
