terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.62.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "AKIA4VIPZL3PS7MQGP4K"
  secret_key = "+mjOTAfvzvoE8f4gPPk775+WWEX856hne4UEDC2W"
}
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16" # Replace with your preferred CIDR block
}

resource "aws_subnet" "example_subnet_1" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.1.0/24" # Replace with your preferred CIDR block
}

resource "aws_subnet" "example_subnet_2" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.2.0/24" # Replace with your preferred CIDR block
}
resource "aws_security_group" "example_alb_sg" {
  name_prefix = "example-alb-sg-"

  ingress {
    from_port   = 80 # Replace with your desired port
    to_port     = 80 # Replace with your desired port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your desired source IP range(s)
  }
}
resource "aws_lb" "application_load_balancer" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.example_alb_sg.id]
  subnets            = [aws_subnet.example_subnet_1.id, aws_subnet.example_subnet_2.id]
  
  tags   = {
    Name = "test"
  }
}

# create target group
resource "aws_lb_target_group" "application_load_balancer" {
  name        = "example-target-group"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.example_vpc.id

  }

# create a listener on port 80 with redirect action
resource "aws_lb_listener" "application_load_balancer" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              =  80
  protocol          = "HTTP" 

  default_action {
    type = "forward"

#     redirect {
#       port        = 443
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
  }
}

# create a listener on port 443 with forward action
