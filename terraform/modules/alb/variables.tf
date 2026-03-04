variable "prefix" {
  description = "Naming prefix for ALB resources (e.g. 'myapp-prod')."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the target group is registered."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the ALB. Use public subnets for internet-facing, private for internal."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs to attach to the ALB."
  type        = list(string)
}

variable "internal" {
  description = "Whether the ALB is internal (private) or internet-facing."
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Prevent accidental deletion of the ALB. Disable before destroying."
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "Idle connection timeout in seconds."
  type        = number
  default     = 60
}

variable "access_logs_bucket" {
  description = "S3 bucket name for ALB access logs. If null, access logging is disabled."
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "S3 key prefix for ALB access logs."
  type        = string
  default     = "alb-access-logs"
}

variable "target_port" {
  description = "Port the target group forwards traffic to."
  type        = number
  default     = 80
}

variable "target_protocol" {
  description = "Protocol used by the target group: HTTP or HTTPS."
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.target_protocol)
    error_message = "target_protocol must be HTTP or HTTPS."
  }
}

variable "target_type" {
  description = "Target type: ip (ECS Fargate), instance (EC2), or lambda."
  type        = string
  default     = "ip"

  validation {
    condition     = contains(["ip", "instance", "lambda"], var.target_type)
    error_message = "target_type must be ip, instance, or lambda."
  }
}

variable "deregistration_delay" {
  description = "Seconds to wait before deregistering a target (allows in-flight requests to complete)."
  type        = number
  default     = 30
}

variable "health_check_path" {
  description = "HTTP path for target health checks."
  type        = string
  default     = "/health"
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successes before a target is considered healthy."
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failures before a target is considered unhealthy."
  type        = number
  default     = 3
}

variable "health_check_timeout" {
  description = "Seconds to wait for a health check response."
  type        = number
  default     = 5
}

variable "health_check_interval" {
  description = "Seconds between health checks."
  type        = number
  default     = 30
}

variable "health_check_matcher" {
  description = "HTTP response codes considered healthy (e.g. '200' or '200-299')."
  type        = string
  default     = "200"
}

variable "enable_https" {
  description = "Whether to create an HTTPS listener and redirect HTTP to HTTPS."
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener. Required when enable_https=true."
  type        = string
  default     = null
}

variable "ssl_policy" {
  description = "SSL negotiation policy for the HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "tags" {
  description = "Map of tags applied to all ALB resources."
  type        = map(string)
  default     = {}
}
