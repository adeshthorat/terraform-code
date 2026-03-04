output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS Task Execution Role."
  value       = try(aws_iam_role.ecs_task_execution[0].arn, null)
}

output "ecs_task_execution_role_name" {
  description = "Name of the ECS Task Execution Role."
  value       = try(aws_iam_role.ecs_task_execution[0].name, null)
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS Task Role (application permissions)."
  value       = try(aws_iam_role.ecs_task[0].arn, null)
}

output "ecs_task_role_name" {
  description = "Name of the ECS Task Role."
  value       = try(aws_iam_role.ecs_task[0].name, null)
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 Instance Profile."
  value       = try(aws_iam_instance_profile.ec2[0].name, null)
}

output "ec2_role_arn" {
  description = "ARN of the EC2 Instance Role."
  value       = try(aws_iam_role.ec2[0].arn, null)
}

output "lambda_role_arn" {
  description = "ARN of the Lambda Execution Role."
  value       = try(aws_iam_role.lambda[0].arn, null)
}

output "lambda_role_name" {
  description = "Name of the Lambda Execution Role."
  value       = try(aws_iam_role.lambda[0].name, null)
}

output "codebuild_role_arn" {
  description = "ARN of the CodeBuild Service Role."
  value       = try(aws_iam_role.codebuild[0].arn, null)
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions OIDC Role."
  value       = try(aws_iam_role.github_actions[0].arn, null)
}
