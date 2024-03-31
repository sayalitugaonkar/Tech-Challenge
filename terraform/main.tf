terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# Configure the AWS Provider
provider "aws" {
  region                   = "ap-south-1"
  shared_credentials_files = ["/home/sayali/.credentials"]
  profile                  = "testing"
}

resource "aws_security_group" "allow_ssh" {
  name        = "Linux_Security_Gp"
  ingress {
    description      = "ssh from bastion"
    from_port        = 22
    to_port          = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol         = "tcp"

  }

    ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol         = "tcp"

  }

  ingress {
    description      = "https"
    from_port        = 443
    to_port          = 443
    cidr_blocks = ["0.0.0.0/0"]
    protocol         = "tcp"

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}


resource "aws_instance" "ec2instance" {
  instance_type = "t3a.medium"
  ami = "${var.ami}" 
  subnet_id = "subnet-0d549bb0c0903c384"
  disable_api_termination = false

  ebs_optimized = false
  key_name = "sayali"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  root_block_device {
    volume_size = "40"
  }
  tags = {
    "Name" = "Magento_Server"
  }
}


