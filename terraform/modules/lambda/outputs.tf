output "function_arn" {
  description = "ARN of the Lambda function."
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Name of the Lambda function."
  value       = aws_lambda_function.this.function_name
}

output "function_invoke_arn" {
  description = "Invoke ARN of the Lambda function (used in API Gateway integrations)."
  value       = aws_lambda_function.this.invoke_arn
}

output "function_version" {
  description = "Published version number of the Lambda function."
  value       = aws_lambda_function.this.version
}

output "log_group_name" {
  description = "CloudWatch Log Group name for this Lambda function."
  value       = aws_cloudwatch_log_group.this.name
}

output "dlq_arn" {
  description = "ARN of the Dead Letter Queue. Null if DLQ is not enabled."
  value       = try(aws_sqs_queue.dlq[0].arn, null)
}

output "alias_arn" {
  description = "ARN of the Lambda alias (live). Null if provisioned concurrency is not configured."
  value       = try(aws_lambda_alias.this[0].arn, null)
}
