output "bucket_ids" {
  description = "Map of logical bucket name => S3 bucket ID."
  value       = { for k, v in aws_s3_bucket.this : k => v.id }
}

output "bucket_arns" {
  description = "Map of logical bucket name => S3 bucket ARN."
  value       = { for k, v in aws_s3_bucket.this : k => v.arn }
}

output "bucket_domain_names" {
  description = "Map of logical bucket name => S3 bucket regional domain name."
  value       = { for k, v in aws_s3_bucket.this : k => v.bucket_regional_domain_name }
}
