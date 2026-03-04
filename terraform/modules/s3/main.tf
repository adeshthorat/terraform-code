###############################################################################
# S3 Module
#
# Creates S3 buckets with production-grade defaults:
#   - All public access blocked
#   - Server-side encryption enabled (AES256 by default, KMS optional)
#   - Versioning optional (default: enabled)
#   - Access logging optional
#   - Lifecycle rules optional
###############################################################################

resource "aws_s3_bucket" "this" {
  for_each = var.buckets

  bucket        = each.value.bucket_name
  force_destroy = each.value.force_destroy

  tags = merge(var.common_tags, each.value.tags, { Name = each.value.bucket_name })
}

###############################################################################
# Block ALL public access (security baseline — always on)
###############################################################################
resource "aws_s3_bucket_public_access_block" "this" {
  for_each = var.buckets

  bucket                  = aws_s3_bucket.this[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

###############################################################################
# Server-Side Encryption
###############################################################################
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = var.buckets

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = each.value.kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = each.value.kms_key_arn
    }
    bucket_key_enabled = each.value.kms_key_arn != null ? true : false
  }
}

###############################################################################
# Versioning
###############################################################################
resource "aws_s3_bucket_versioning" "this" {
  for_each = { for k, v in var.buckets : k => v if v.versioning_enabled }

  bucket = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

###############################################################################
# Access Logging
###############################################################################
resource "aws_s3_bucket_logging" "this" {
  for_each = { for k, v in var.buckets : k => v if v.access_log_bucket != null }

  bucket        = aws_s3_bucket.this[each.key].id
  target_bucket = each.value.access_log_bucket
  target_prefix = "s3-access-logs/${each.value.bucket_name}/"
}

###############################################################################
# Lifecycle Rules
###############################################################################
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = { for k, v in var.buckets : k => v if length(v.lifecycle_rules) > 0 }

  depends_on = [aws_s3_bucket_versioning.this]

  bucket = aws_s3_bucket.this[each.key].id

  dynamic "rule" {
    for_each = each.value.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration_days != null ? [1] : []
        content {
          days = rule.value.expiration_days
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions
        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration_days != null ? [1] : []
        content {
          noncurrent_days = rule.value.noncurrent_version_expiration_days
        }
      }
    }
  }
}
