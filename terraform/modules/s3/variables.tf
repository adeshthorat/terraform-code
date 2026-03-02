variable "buckets" {
  type = map(object({
    bucket_name        = string
    acl                = optional(string, "private")
    versioning_enabled = optional(bool, false)
    tags               = optional(map(string), {})
  }))
  description = "Map of bucket configurations"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
