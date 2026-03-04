output "repository_url" {
  description = "Full URI of the ECR repository (e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-repo)."
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository."
  value       = aws_ecr_repository.this.arn
}

output "repository_name" {
  description = "Name of the ECR repository."
  value       = aws_ecr_repository.this.name
}

output "registry_id" {
  description = "AWS account ID associated with the ECR registry."
  value       = aws_ecr_repository.this.registry_id
}
