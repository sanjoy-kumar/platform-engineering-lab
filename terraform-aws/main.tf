# Define Custom VPC Infrastructure

# --- Start VPC Infrastructure -----------

## - 1. VPC & Internet Gateway:Creates an isolated virtual network (10.0.0.0/16) and attaches an Internet Gateway to enable public internet access.
### 1.1 VPC

resource "aws_vpc" "custom_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "custom-vpc"
    }
}

### 1.2 Internat Gateway

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.custom_vpc.id
    tags = {
        Name = "igw"
    }
}

## 2. - Public Subnets: Deploys two public subnets across different Availability Zones (us-east-2a and us-east-2b) for the ALB.

### 2.1. Public Subnet 1 (AZ is us-east-2a)

resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.custom_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-2a"
    map_public_ip_on_launch = true
    tags = {
        Name = "Public-Subnet-1"
    }
}

### 2.2. Public Subnet 2 (AZ is us-east-2b)

resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.custom_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-2b"
    map_public_ip_on_launch = true
    tags = {
        Name = "Public-Subnet-2"
    }
}

## - 3. Route Table: Maps 0.0.0.0/0 traffic from public subnets to the Internet Gateway.


### 3.1  Route Table

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.custom_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
            Name = "public-route-table"
        }

}


### 3.2  Association

resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "b" {
    subnet_id = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.public_rt.id
}

### --- End VPC Infrastructure -----------


# Configure Tiered Security Groups

### 4. Security Groups

### 4.1 Security Group for Load Balancer

resource "aws_security_group" "alb_sg" {
    name = "alb-sg"
    description = "Allow inbound HTTP/HTTPS traffice to ALB"
    vpc_id = aws_vpc.custom_vpc.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

### 4.2 Security Group for EC2 / Auto Scaling Group

resource "aws_security_group" "web_sg" {
    name = "app-sg"
    description = "Allow HTTP and SSH traffic from ALB"
    vpc_id = aws_vpc.custom_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # HTTP restricted to ALB security group
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

# 5.Convert aws_instance to aws_launch_template:
### Prepare instance configuration for auto-scaling.
### - Launch Template: Replaces standalone aws_instance so Auto Scaling can dynamically spawn copies.
### - User Data: Base64-encoded user script running updates during launch.
### - Storage & Keys: Keeps your 30GB gp3 root block configuration and openclaw-key.

resource "aws_launch_template" "web_template" {
  name_prefix   = "web-server-template-"
  image_id      = "ami-0e5497a77ef21b5ac"
  instance_type = var.instance_type
  key_name      = "openclaw-key"

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt upgrade -y
              apt install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-server-asg"
    }
  }
}



