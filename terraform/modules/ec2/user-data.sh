#!/bin/bash
echo "Hello, World! This is an EC2 instance provisioned by Terraform." > /var/www/html/index.html
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
