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
  user_data = file("userdata.sh")
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
  user_data = file("userdata.sh")
  vpc_security_group_ids = [aws_security_group.not_secure_group.id]


  tags = {
    Name  = "Instance number ${var.instance_count + count.index + 1}"
  }
}

data "aws_vpc" "vpc" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }
}

resource "aws_security_group" "not_secure_group" {
  description = "allows everything"
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "alb" {
  name = "alb"
  subnets = data.aws_subnets.all.ids
  security_groups = [aws_security_group.not_secure_group.id]
}

resource "aws_alb_target_group" "cluster1" {
  name = "cluster1"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_alb_target_group" "cluster2" {
  name = "cluster2"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {    
    target_group_arn = aws_alb_target_group.cluster1.arn
    type             = "forward"  
  }
}

resource "aws_alb_listener_rule" "cluster1_rule" {
  listener_arn = aws_alb_listener.listener.arn
  
  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.cluster1.arn
  }

  condition {
    path_pattern {
      values = ["/cluster1"]
    }  
  }
}

resource "aws_alb_listener_rule" "cluster2_rule" {
  listener_arn = aws_alb_listener.listener.arn

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.cluster2.arn
  }

  condition {
    path_pattern {
      values = ["/cluster2"]
    }  
  }
}

resource "aws_alb_target_group_attachment" "cluster1_external" {
  for_each = {for id, attributes in aws_instance.cluster1_instances: id => attributes}
  target_group_arn = aws_alb_target_group.cluster1.arn
  target_id = each.value.id
  port = 80
}

resource "aws_alb_target_group_attachment" "cluster2_external" {
  for_each = {for id, attributes in aws_instance.cluster2_instances: id => attributes}
  target_group_arn = aws_alb_target_group.cluster2.arn
  target_id = each.value.id
  port = 80
}

output "dns_address" {
  description = "Application DNS name"
  value = aws_alb.alb.dns_name
}
