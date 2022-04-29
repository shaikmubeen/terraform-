terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAXJGFSTRPXAUCVTUB"
  secret_key = "jbb27wW26SrUSwJ54dBjfamrpuz8LIPB6c4Fu"
  profile    = "terraform"
}

#Resources
#create vpc
resource "aws_vpc" "vpc1" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "vpc1-1"
  }
}

#creating internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "IGW"
  }
}
#public subnet
resource "aws_subnet" "pub-sub1" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "PUB-SUB-1"
  }
}
#private subnet
resource "aws_subnet" "prv-sub1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "PRV-SUB-1"
  }

}
#public  Route tables
resource "aws_route_table" "pub-rt-tab" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PUB-RT-TB"
  }
}
#private  Route tables
resource "aws_route_table" "prv-rt-tab" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "Prv-RT-TB"
  }
}
#public subnet association
resource "aws_route_table_association" "pub-assc" {
  subnet_id      = aws_subnet.pub-sub1.id
  route_table_id = aws_route_table.pub-rt-tab.id
}
#prviate  subnet association
resource "aws_route_table_association" "prv-assc" {
  subnet_id      = aws_subnet.prv-sub1.id
  route_table_id = aws_route_table.prv-rt-tab.id
}


#creation of security group
resource "aws_security_group" "web-sec" {
  name        = "web-sec"
  description = "Allow ssh and http inbound traffic"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WEB-SEC"
  }
}

# creation of ec2 instance
resource "aws_instance" "ec2-user-instance" {
  ami                    = "ami-0f9fc25dd2506cf6d" # us-east-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.pub-sub1.id
  vpc_security_group_ids = [aws_security_group.web-sec.id]
  key_name               = "first1-key"
  count                  = 1
  #user_data              = file("ecomm.sh")
  tags = {
    Name = "EC2"
  }

}
















