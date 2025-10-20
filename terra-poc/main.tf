resource "aws_instance" "this" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = var.subnet_id
  security_groups      = var.security_groups
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  root_block_device {
    volume_type = var.root_block_device.volume_type
    volume_size = var.root_block_device.volume_size
    encrypted   = var.root_block_device.encrypted
    kms_key_id  = var.root_block_device.kms_key_id
  }
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags
    ]
  }

  tags = {
    Name     = "AWS${var.environment}${local.generate_id}"
    Team     = local.Team
    AppOwner = "adesh_thorat"
  }

}

resource "aws_security_group" "restricted_sg" {
  name        = "tf-restricted-sg"
  description = "Allow SSH only from caller IP (as provided in variable my_ip_cidr)"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-restricted-sg"
  }
}


locals {
  Team        = "${var.environment}-Team"
  created_on  = timestamp()
  generate_id = random_integer.server.id
  AppOwner    = "adesh_thorat"

}

resource "random_integer" "server" {
  min = 10000
  max = 99999
}

data "aws_iam_policy_document" "s3_upload_policy" {
  statement {
    sid    = "AllowPutObjectToSpecificBucket"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.upload_bucket.arn,
      "${aws_s3_bucket.upload_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_role" "s3_upload_role" {
  name               = "tf-s3-upload-role"
  assume_role_policy = data.aws_iam_policy_document.s3_upload_policy.json
}

resource "aws_iam_policy" "s3_upload_policy" {
  name        = "tf-s3-upload-policy"
  description = "Allow EC2 to upload objects to the Terraform-created S3 bucket"
  policy      = data.aws_iam_policy_document.s3_upload_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.s3_upload_role.name
  policy_arn = aws_iam_policy.s3_upload_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "tf-ec2-instance-profile"
  role = aws_iam_role.s3_upload_role.name
}
resource "aws_s3_bucket" "upload_bucket" {
  bucket = "tf-upload-bucket-${random_integer.server.id}"

  tags = {
    Name = "tf-upload-bucket"
  }
  force_destroy = true
}
