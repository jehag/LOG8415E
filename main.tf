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

resource "aws_instance" "cluster1_instances" {
  count         = var.instance_count
  ami           = "ami-0149b2da6ceec4bb0"
  instance_type = var.instance_type[0]
  availability_zone = var.availability_zone[count.index % 2]
  user_data = "userdata.sh"
  vpc_security_group_ids = [aws_security_group.not_secure_group.id]

  tags = {
    Name  = "Instance number ${count.index + 1}"
  }
}

resource "aws_instance" "cluster2_instances" {
  count         = var.instance_count
  ami           = "ami-0149b2da6ceec4bb0"
  instance_type = var.instance_type[1]
  availability_zone = var.availability_zone[count.index % 2]
  user_data = "userdata.sh"
  vpc_security_group_ids = [aws_security_group.not_secure_group.id]


  tags = {
    Name  = "Instance number ${var.instance_count + count.index + 1}"
  }
}

