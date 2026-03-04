variable "repository_name" {
  description = "Name of the ECR repository. Must be unique within the AWS account and region."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9/_.-]{1,255}$", var.repository_name))
    error_message = "repository_name must be lowercase alphanumeric with optional /, _, ., - characters."
  }
}

variable "image_tag_mutability" {
  description = "Tag mutability setting: IMMUTABLE (default, prevents overwriting tags) or MUTABLE."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["IMMUTABLE", "MUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be IMMUTABLE or MUTABLE."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN for repository encryption. If null, AES256 is used."
  type        = string
  default     = null
}

variable "max_image_count" {
  description = "Maximum number of tagged images to retain in the repository."
  type        = number
  default     = 30
}

variable "untagged_image_expiry_days" {
  description = "Number of days after which untagged images are expired."
  type        = number
  default     = 14
}

variable "lifecycle_tag_prefixes" {
  description = "List of tag prefixes tracked by the max_image_count lifecycle rule."
  type        = list(string)
  default     = ["v"]
}

variable "repository_policy_json" {
  description = "JSON-encoded IAM policy document for the repository (e.g. cross-account access). If null, no policy is attached."
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags applied to the ECR repository."
  type        = map(string)
  default     = {}
}
