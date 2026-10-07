terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "us-east-1"
}

variable "app_name" {
  default = "devsecops-demo"
}

# VULN 1: S3 bucket with no public access block
# Checkov will flag: CKV_AWS_53, CKV_AWS_54
resource "aws_s3_bucket" "app_assets" {
  bucket = "${var.app_name}-assets"
}

# VULN 2: Security group with SSH open to world
# Checkov will flag: CKV_AWS_25
resource "aws_security_group" "app_sg" {
  name        = "${var.app_name}-sg"
  description = "App security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# VULN 3: EC2 with unencrypted root volume
# Checkov will flag: CKV_AWS_8
resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  root_block_device {
    encrypted = false
  }

  tags = {
    Name = var.app_name
  }
}