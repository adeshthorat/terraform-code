variable "prefix" {
  description = "Naming prefix for all ECS resources (e.g. 'myapp-prod')."
  type        = string
}

variable "service_name" {
  description = "Short name for the ECS service (e.g. 'api', 'worker'). Combined with prefix to form resource names."
  type        = string
  default     = "app"
}

variable "aws_region" {
  description = "AWS region for CloudWatch log group configuration in the container definition."
  type        = string
  default     = "us-east-1"
}

###############################################################################
# Cluster settings
###############################################################################
variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for the ECS cluster."
  type        = bool
  default     = true
}

variable "capacity_providers" {
  description = "List of capacity providers to associate with the cluster."
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider_strategy" {
  description = "Default capacity provider strategy for the cluster."
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = optional(number, 0)
  }))
  default = [
    { capacity_provider = "FARGATE", weight = 1, base = 1 },
    { capacity_provider = "FARGATE_SPOT", weight = 4, base = 0 }
  ]
}

###############################################################################
# Task definition
###############################################################################
variable "task_cpu" {
  description = "CPU units for the task (256 = 0.25 vCPU, 512 = 0.5 vCPU, 1024 = 1 vCPU)."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory (MiB) for the task."
  type        = number
  default     = 512
}

variable "execution_role_arn" {
  description = "ARN of the ECS Task Execution Role (pulls images, writes logs)."
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS Task Role (application-level AWS permissions). Set null if not needed."
  type        = string
  default     = null
}

variable "container_name" {
  description = "Name of the primary container in the task definition."
  type        = string
  default     = "app"
}

variable "container_image" {
  description = "Docker image URI (e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:v1)."
  type        = string
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 8080
}

variable "environment_variables" {
  description = "Map of environment variable name => value injected into the container."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Map of environment variable name => SSM Parameter or Secrets Manager ARN. Values are injected as secrets."
  type        = map(string)
  default     = {}
}

variable "readonly_root_filesystem" {
  description = "Whether the container's root filesystem is read-only (security hardening)."
  type        = bool
  default     = false
}

variable "container_definition_overrides" {
  description = "Additional key-value pairs merged into the container definition (for advanced use cases)."
  type        = any
  default     = {}
}

variable "log_retention_days" {
  description = "Number of days to retain ECS task logs in CloudWatch."
  type        = number
  default     = 90
}

###############################################################################
# Service settings
###############################################################################
variable "desired_count" {
  description = "Desired number of running task replicas."
  type        = number
  default     = 2
}

variable "subnet_ids" {
  description = "Private subnet IDs in which ECS tasks run."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs attached to ECS tasks."
  type        = list(string)
}

variable "target_group_arn" {
  description = "ALB target group ARN. If null, no load balancer is attached."
  type        = string
  default     = null
}

variable "health_check_grace_period" {
  description = "Seconds ECS waits before starting health checks on a newly launched task."
  type        = number
  default     = 60
}

variable "enable_execute_command" {
  description = "Enables ECS Exec for interactive debugging into containers. Disable in strict production."
  type        = bool
  default     = false
}

variable "force_new_deployment" {
  description = "Force a new ECS service deployment on every Terraform apply (useful for image-tag:latest pipelines)."
  type        = bool
  default     = false
}

variable "service_capacity_provider_strategy" {
  description = "Capacity provider strategy for the ECS service. Overrides cluster default when set."
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = optional(number, 0)
  }))
  default = []
}

###############################################################################
# Auto Scaling
###############################################################################
variable "enable_autoscaling" {
  description = "Whether to enable ECS service auto scaling."
  type        = bool
  default     = true
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks when auto scaling is enabled."
  type        = number
  default     = 2
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks when auto scaling is enabled."
  type        = number
  default     = 10
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for auto scaling."
  type        = number
  default     = 60
}

variable "autoscaling_memory_target" {
  description = "Target memory utilization percentage for auto scaling."
  type        = number
  default     = 70
}

variable "autoscaling_scale_in_cooldown" {
  description = "Seconds to wait after a scale-in event before another can occur."
  type        = number
  default     = 300
}

variable "autoscaling_scale_out_cooldown" {
  description = "Seconds to wait after a scale-out event before another can occur."
  type        = number
  default     = 60
}

variable "tags" {
  description = "Map of tags applied to all ECS resources."
  type        = map(string)
  default     = {}
}
