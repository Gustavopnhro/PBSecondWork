terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_security_group" "lb-security-group" {
  name        = "lb-sg-002"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "vpc-077cfb20f2b04d64a"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "efs-security-group" {
  name        = "efs-sg-002"
  description = "Allow NFS inbound traffic"
  vpc_id      = "vpc-077cfb20f2b04d64a"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    security_groups = [aws_security_group.lb-security-group.id]
  }

  egress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "rds-security-group" {
  name        = "rds-sg-002"
  description = "Allow MySQL inbound traffic"
  vpc_id      = "vpc-077cfb20f2b04d64a"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2-security-group" {
  name        = "ec2-sg-002"
  description = "Allow Load Balancer inbound traffic"
  vpc_id      = "vpc-077cfb20f2b04d64a"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lb-security-group.id]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}