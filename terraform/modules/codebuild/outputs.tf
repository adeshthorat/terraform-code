output "project_name" {
  description = "Name of the CodeBuild project."
  value       = aws_codebuild_project.this.name
}

output "project_arn" {
  description = "ARN of the CodeBuild project."
  value       = aws_codebuild_project.this.arn
}

output "project_id" {
  description = "ID of the CodeBuild project."
  value       = aws_codebuild_project.this.id
}

output "log_group_name" {
  description = "CloudWatch Log Group name for this CodeBuild project."
  value       = aws_cloudwatch_log_group.this.name
}

output "s3_cache_bucket_id" {
  description = "ID of the S3 cache bucket. Null if S3 cache is disabled."
  value       = try(aws_s3_bucket.cache[0].id, null)
}
