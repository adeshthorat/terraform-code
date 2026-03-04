variable "prefix" {
  description = "Naming prefix for all ASG resources (e.g. 'myapp-prod')."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances launched by the ASG."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (e.g. t3.medium)."
  type        = string
  default     = "t3.medium"
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the ASG. Instances launch across these subnets."
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs attached to every launched instance."
  type        = list(string)
}

variable "instance_profile_name" {
  description = "IAM Instance Profile name. Recommended for SSM Session Manager access."
  type        = string
  default     = null
}

variable "key_name" {
  description = "EC2 key pair name. Leave null to disable SSH (use SSM instead)."
  type        = string
  default     = null
}

variable "user_data" {
  description = "User-data script as a plain string (not a file path). Base64-encoding is handled automatically."
  type        = string
  default     = null
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Root EBS volume type (gp3 recommended for cost/performance)."
  type        = string
  default     = "gp3"
}

variable "kms_key_id" {
  description = "KMS Key ID/ARN for EBS encryption. If null, AWS-managed key is used."
  type        = string
  default     = null
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed (1-minute) CloudWatch metrics for launched instances."
  type        = bool
  default     = false
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG."
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of instances in the ASG."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the ASG."
  type        = number
  default     = 4
}

variable "target_group_arns" {
  description = "List of ALB/NLB target group ARNs to associate with the ASG."
  type        = list(string)
  default     = []
}

variable "health_check_type" {
  description = "Health check type: EC2 (instance-level) or ELB (load balancer health check)."
  type        = string
  default     = "ELB"

  validation {
    condition     = contains(["EC2", "ELB"], var.health_check_type)
    error_message = "health_check_type must be EC2 or ELB."
  }
}

variable "health_check_grace_period" {
  description = "Seconds to wait after instance launch before health checks begin."
  type        = number
  default     = 120
}

variable "instance_refresh_min_healthy_percentage" {
  description = "Minimum percentage of healthy instances during a rolling update."
  type        = number
  default     = 90
}

variable "instance_refresh_warmup" {
  description = "Seconds until a new instance contributes to the health check during a refresh."
  type        = number
  default     = 120
}

###############################################################################
# Scaling Policies
###############################################################################
variable "enable_cpu_scaling_policy" {
  description = "Whether to create a CPU-based target tracking scaling policy."
  type        = bool
  default     = true
}

variable "cpu_scaling_target_value" {
  description = "Target average CPU utilization percentage for auto scaling."
  type        = number
  default     = 60
}

variable "enable_alb_request_scaling_policy" {
  description = "Whether to create an ALB request-count target tracking scaling policy."
  type        = bool
  default     = false
}

variable "alb_request_scaling_target_value" {
  description = "Target ALB requests-per-target for scaling."
  type        = number
  default     = 1000
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix (the part after 'app/') required for ALB request scaling. Obtain from aws_lb.this.arn_suffix."
  type        = string
  default     = null
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix required for ALB request scaling. Obtain from aws_lb_target_group.this.arn_suffix."
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags applied to all ASG resources and propagated to instances."
  type        = map(string)
  default     = {}
}
