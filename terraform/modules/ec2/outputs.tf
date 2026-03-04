output "instance_ids" {
  description = "Map of logical instance name => EC2 instance ID."
  value       = { for k, v in aws_instance.this : k => v.id }
}

output "private_ips" {
  description = "Map of logical instance name => private IP address."
  value       = { for k, v in aws_instance.this : k => v.private_ip }
}

output "public_ips" {
  description = "Map of logical instance name => public IP address (null if no public IP assigned)."
  value       = { for k, v in aws_instance.this : k => v.public_ip }
}

output "instance_arns" {
  description = "Map of logical instance name => instance ARN."
  value       = { for k, v in aws_instance.this : k => v.arn }
}
