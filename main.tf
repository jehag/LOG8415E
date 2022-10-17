terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

/*
 * aws provider to access and create instances
 * credentials were not put here, as we assume they already exist in the ~/.aws/credentials file
 */
provider "aws" {
  region  = "us-east-1"
}

/*
 * cluster 1 instances
 * will be initialized with the userdata.sh to serve the flaskapp
 * refer to variable.tf for more information on count and type
 */
resource "aws_instance" "cluster1_instances" {
  count         = var.instance_count[0]
  ami           = "ami-0149b2da6ceec4bb0"
  instance_type = var.instance_type[0]
  availability_zone = var.availability_zone[count.index % 2]
  user_data = file("userdata.sh")
  vpc_security_group_ids = [aws_security_group.not_secure_group.id]

  tags = {
    Name  = "Instance number ${count.index + 1}"
  }
}

/*
 * cluster 2 instances
 * will be initialized with the userdata.sh to serve the flaskapp
 * refer to variable.tf for more information on count and type
 */
resource "aws_instance" "cluster2_instances" {
  count         = var.instance_count[1]
  ami           = "ami-0149b2da6ceec4bb0"
  instance_type = var.instance_type[1]
  availability_zone = var.availability_zone[count.index % 2]
  user_data = file("userdata.sh")
  vpc_security_group_ids = [aws_security_group.not_secure_group.id]


  tags = {
    Name  = "Instance number ${var.instance_count[0] + count.index + 1}"
  }
}

/*
 * default vpc from the aws account
 * as multiple vpc cannot exist in the same availability zone, 
 * we opted to use the default vpc for this configuration.
 */
data "aws_vpc" "vpc" {
  default = true
}

/*
 * subnets from the default vpc
 * the default vpc has 6 subnets, one for each availability zone. 
 */
data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

/*
 * security group for the configuration
 * this security group allows all inbound and outbound traffic.
 * while this configuration does not pose any problem for the current use case,
 * it should be used carefully as it can become a source of security issues, 
 * due to the absence of inbound restrictions.
 */
resource "aws_security_group" "not_secure_group" {
  description = "allows everything"
  vpc_id = data.aws_vpc.vpc.id

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

/*
 * application load balancer
 * active on all subnets
 */
resource "aws_alb" "alb" {
  name = "alb"
  subnets = data.aws_subnets.all.ids
  security_groups = [aws_security_group.not_secure_group.id]
}

/*
 * cluster1 target group
 */
resource "aws_alb_target_group" "cluster1" {
  name = "cluster1"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.vpc.id

  health_check {
    path = "/cluster1"
    port = 80
  }
}

/*
 * cluster2 target group
 */
resource "aws_alb_target_group" "cluster2" {
  name = "cluster2"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.vpc.id

  health_check {
    path = "/cluster2"
    port = 80
  }
}

/*
 * load balancer listener
 * redirects all http requests with path '/' to cluster1
 */
resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {    
    target_group_arn = aws_alb_target_group.cluster1.arn
    type             = "forward"
  }
}

/*
 * load balancer listener rule for cluster1
 * redirects all http requests with path '/cluster1' to cluster1
 */
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

/*
 * load balancer listener rule for cluster2
 * redirects all http requests with path '/cluster2' to cluster2
 */
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

/*
 * target group attachment ressource for cluster1
 * associates every instance from cluster1 to the cluster1 target group 
 */
resource "aws_alb_target_group_attachment" "cluster1_external" {
  for_each = {for id, attributes in aws_instance.cluster1_instances: id => attributes}
  target_group_arn = aws_alb_target_group.cluster1.arn
  target_id = each.value.id
  port = 80
}

/*
 * target group attachment ressource for cluster2
 * associates every instance from cluster2 to the cluster2 target group 
 */
resource "aws_alb_target_group_attachment" "cluster2_external" {
  for_each = {for id, attributes in aws_instance.cluster2_instances: id => attributes}
  target_group_arn = aws_alb_target_group.cluster2.arn
  target_id = each.value.id
  port = 80
}

/*
 * outputs
 * used for various purposes (http requests to alb, benchmarking)
 */
output "dns_address" {
  description = "Application DNS name"
  value = aws_alb.alb.dns_name
}

output "lb_arn_suffix" {
  description = "Application load balancer arn suffix"
  value = aws_alb.alb.arn_suffix
}

output "cluster1_arn_suffix" {
  description = "Cluster 1 arn suffix"
  value = aws_alb_target_group.cluster1.arn_suffix
}

output "cluster2_arn_suffix" {
  description = "Cluster 2 arn suffix"
  value = aws_alb_target_group.cluster2.arn_suffix
}