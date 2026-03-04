variable "common_tags" {
  description = "Tags applied to every bucket created by this module."
  type        = map(string)
  default     = {}
}

variable "buckets" {
  description = <<-EOT
    Map of S3 bucket configurations. Key = logical name, value = bucket settings.

    - bucket_name                        (required) — must be globally unique.
    - versioning_enabled                 (optional, default true) — enable S3 versioning.
    - force_destroy                      (optional, default false) — allow destroy even with objects.
    - kms_key_arn                        (optional, default null) — use KMS instead of AES256.
    - access_log_bucket                  (optional, default null) — S3 bucket name for access logs.
    - tags                               (optional, default {}) — per-bucket tags merged with common_tags.
    - lifecycle_rules                    (optional, default []) — list of lifecycle rule objects.
  EOT

  type = map(object({
    bucket_name         = string
    versioning_enabled  = optional(bool, true)
    force_destroy       = optional(bool, false)
    kms_key_arn         = optional(string, null)
    access_log_bucket   = optional(string, null)
    tags                = optional(map(string), {})

    lifecycle_rules = optional(list(object({
      id      = string
      enabled = optional(bool, true)

      transitions = optional(list(object({
        days          = number
        storage_class = string
      })), [])

      expiration_days = optional(number, null)

      noncurrent_version_transitions = optional(list(object({
        days          = number
        storage_class = string
      })), [])

      noncurrent_version_expiration_days = optional(number, null)
    })), [])
  }))

  default = {}
}
