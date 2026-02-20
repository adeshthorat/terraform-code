#!/bin/bash
echo "Hello, World! This is an EC2 instance provisioned by Terraform." > /var/www/html/index.html
apt update -y
apt install -y nginx
systemctl start nginx
systemctl enable nginx
