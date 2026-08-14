
resource "aws_instance" "web_server" {
    ami = "ami-0e5497a77ef21b5ac"
    instance_type = var.instance_type
    vpc_security_group_ids = [ aws_security_group.web_sg.id ]
    key_name = "openclaw-key"
    
    root_block_device {
        volume_size = 30
        volume_type = "gp3"
        delete_on_termination = true
    }

    tags  = {
        Name = "web-server"
    }

    user_data = <<EOF
          #!/bin/bash
          apt update -y
          apt upgrade -y
        EOF

}



resource "aws_security_group" "web_sg" {
    name = "web-sg"
    description = "Allow SSH, HTTP and HTTPS traffic."

    # SSH 
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    # HTTP

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    # HTTPS

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }


    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

}


# Define Custom VPC Infrastructure
# --- Start -----------
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



## - Route Table: Maps 0.0.0.0/0 traffic from public subnets to the Internet Gateway.
