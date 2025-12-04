resource "aws_instance" "ec2" {
  for_each = var.instances

  ami                         = var.ami_id
  instance_type               = each.value.instance_type
  subnet_id                   = var.subnet_id
  security_groups             = [aws_security_group.allow_tls.id]
  associate_public_ip_address = false

  tags = merge(var.tags, var.tags-all, { "Name" = "${each.key}" })

  depends_on = [aws_security_group.allow_tls]
}


data "aws_vpc" "this" {
  default = true
}



resource "aws_security_group" "allow_tls" {

  name        = "Allow Port 443/80"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.this.id

  dynamic "ingress" {
    for_each = var.sg-ports
    iterator = port

    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "egress" {
    for_each = var.sg-ports

    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name = "Application-sg"
  }

  lifecycle {
    create_before_destroy = true
  }

}
