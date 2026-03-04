###############################################################################
# Lambda Module
#
# Creates:
#   - Lambda function with configurable runtime, handler, and source
#   - CloudWatch Log Group with configurable retention
#   - Dead Letter Queue (SQS) for failed invocations (optional)
#   - X-Ray tracing (optional)
#   - VPC configuration (optional)
#   - Reserved and provisioned concurrency (optional)
###############################################################################

###############################################################################
# CloudWatch Log Group (created before the function to ensure retention applies)
###############################################################################
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

###############################################################################
# Dead Letter Queue
###############################################################################
resource "aws_sqs_queue" "dlq" {
  count = var.enable_dlq ? 1 : 0

  name                      = "${var.function_name}-dlq"
  message_retention_seconds = 1209600 # 14 days (max)
  kms_master_key_id         = var.dlq_kms_key_id

  tags = var.tags
}

###############################################################################
# Lambda Function
###############################################################################
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  description   = var.description
  role          = var.execution_role_arn
  handler       = var.handler
  runtime       = var.runtime

  filename         = var.source_type == "zip" ? var.source_path : null
  s3_bucket        = var.source_type == "s3" ? var.s3_bucket : null
  s3_key           = var.source_type == "s3" ? var.s3_key : null
  s3_object_version = var.source_type == "s3" ? var.s3_object_version : null
  source_code_hash = var.source_type == "zip" && var.source_path != null ? filebase64sha256(var.source_path) : null

  timeout                        = var.timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions

  environment {
    variables = var.environment_variables
  }

  # X-Ray tracing
  tracing_config {
    mode = var.enable_xray_tracing ? "Active" : "PassThrough"
  }

  # Dead Letter Queue
  dynamic "dead_letter_config" {
    for_each = var.enable_dlq ? [1] : []
    content {
      target_arn = aws_sqs_queue.dlq[0].arn
    }
  }

  # VPC configuration
  dynamic "vpc_config" {
    for_each = length(var.vpc_subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  # Ephemeral storage (/tmp)
  ephemeral_storage {
    size = var.ephemeral_storage_mb
  }

  depends_on = [aws_cloudwatch_log_group.this]

  tags = var.tags
}

###############################################################################
# Provisioned Concurrency (optional — reduces cold starts for latency-sensitive functions)
###############################################################################
resource "aws_lambda_provisioned_concurrency_config" "this" {
  count = var.provisioned_concurrent_executions > 0 ? 1 : 0

  function_name                     = aws_lambda_function.this.function_name
  qualifier                         = aws_lambda_alias.this[0].name
  provisioned_concurrent_executions = var.provisioned_concurrent_executions
}

resource "aws_lambda_alias" "this" {
  count = var.provisioned_concurrent_executions > 0 ? 1 : 0

  name             = "live"
  function_name    = aws_lambda_function.this.function_name
  function_version = aws_lambda_function.this.version
}
