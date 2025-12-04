#!/bin/bash
yum update -y
amazon-linux-extras install nginx1 -y
systemctl enable nginx
systemctl start nginx

echo "Welcome to ${env} - ${app}" > /usr/share/nginx/html/index.html
