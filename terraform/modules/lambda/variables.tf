variable "function_name" {
  description = "Unique name for the Lambda function."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,64}$", var.function_name))
    error_message = "function_name must be 1-64 characters: letters, numbers, underscores, and hyphens only."
  }
}

variable "description" {
  description = "Human-readable description of the Lambda function."
  type        = string
  default     = "Managed by Terraform"
}

variable "execution_role_arn" {
  description = "ARN of the IAM role assumed by the Lambda function."
  type        = string
}

variable "handler" {
  description = "Function handler in 'file.method' format (e.g. 'main.handler' for Node.js, 'app.handler' for Python)."
  type        = string
  default     = "main.handler"
}

variable "runtime" {
  description = "Lambda runtime identifier (e.g. python3.12, nodejs20.x, java21)."
  type        = string
  default     = "python3.12"

  validation {
    condition = contains([
      "python3.9", "python3.10", "python3.11", "python3.12",
      "nodejs18.x", "nodejs20.x",
      "java11", "java17", "java21",
      "dotnet6", "dotnet8",
      "provided.al2", "provided.al2023"
    ], var.runtime)
    error_message = "runtime must be a valid, non-deprecated Lambda runtime identifier."
  }
}

variable "source_type" {
  description = "Source package type: 'zip' (local file) or 's3' (S3 object)."
  type        = string
  default     = "zip"

  validation {
    condition     = contains(["zip", "s3"], var.source_type)
    error_message = "source_type must be zip or s3."
  }
}

variable "source_path" {
  description = "Path to the deployment package zip file. Required when source_type='zip'."
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing the deployment package. Required when source_type='s3'."
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of the deployment package. Required when source_type='s3'."
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "S3 object version of the deployment package. Recommended to pin deployments."
  type        = string
  default     = null
}

variable "timeout" {
  description = "Maximum execution time in seconds (1–900)."
  type        = number
  default     = 30

  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "timeout must be between 1 and 900 seconds."
  }
}

variable "memory_size" {
  description = "Memory allocated to the function in MB (128–10240). CPU scales proportionally."
  type        = number
  default     = 128

  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "memory_size must be between 128 and 10240 MB."
  }
}

variable "reserved_concurrent_executions" {
  description = "Maximum number of concurrent executions. Set to 0 to throttle completely. -1 for unreserved."
  type        = number
  default     = -1
}

variable "provisioned_concurrent_executions" {
  description = "Number of provisioned concurrency units. 0 disables provisioned concurrency."
  type        = number
  default     = 0
}

variable "environment_variables" {
  description = "Map of environment variables injected into the Lambda function."
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "Number of days to retain Lambda logs in CloudWatch."
  type        = number
  default     = 90
}

variable "enable_xray_tracing" {
  description = "Enable AWS X-Ray active tracing for the function."
  type        = bool
  default     = true
}

variable "enable_dlq" {
  description = "Whether to create an SQS Dead Letter Queue for failed async invocations."
  type        = bool
  default     = true
}

variable "dlq_kms_key_id" {
  description = "KMS key ID for DLQ encryption. Null uses AWS-managed key."
  type        = string
  default     = null
}

variable "vpc_subnet_ids" {
  description = "Subnet IDs when the Lambda runs inside a VPC. Leave empty for public (no VPC)."
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Security group IDs when the Lambda runs inside a VPC."
  type        = list(string)
  default     = []
}

variable "ephemeral_storage_mb" {
  description = "Size of the /tmp directory in MB (512–10240)."
  type        = number
  default     = 512

  validation {
    condition     = var.ephemeral_storage_mb >= 512 && var.ephemeral_storage_mb <= 10240
    error_message = "ephemeral_storage_mb must be between 512 and 10240 MB."
  }
}

variable "tags" {
  description = "Map of tags applied to all Lambda resources."
  type        = map(string)
  default     = {}
}
