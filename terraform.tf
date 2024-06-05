terraform {
  required_providers {
    aws={
        source  = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = var.aws-region
}

resource "aws_vpc" "dev-vpc-tf-cloud" {
  cidr_block   = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Dev-Cloud-VPC"
  }
}

resource "aws_subnet" "dev-public-sub-01"{
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "Dev-Cloud-Subnet-01-Public"
  }
}

resource "aws_subnet" "dev-private-sub-01"{
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "Dev-Cloud-Subnet-01-Private"
  }
}

resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id
  tags = {
    Name = "Dev-Cloud-IGW"
  }
}

resource "aws_route_table" "dev-public-rt-01" {
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id
  tags = {
    Name = "Dev-Cloud-RT-01-Public"
  }
}

resource "aws_route_table" "dev-private-rt-01" {
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id
  tags = {
    Name = "Dev-Cloud-RT-01-Private"
  }
}

resource "aws_route_table_association" "dev-rt-01-associate-pub-01" {
  subnet_id = aws_subnet.dev-public-sub-01.id
  route_table_id = aws_route_table.dev-public-rt-01.id
}

resource "aws_route" "dev-public-rt-01-route-01" {
  depends_on = [aws_internet_gateway.dev-igw]
  route_table_id = aws_route_table.dev-public-rt-01.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.dev-igw.id
}

resource "aws_route_table_association" "dev-rt-01-associate-pvt" {
  subnet_id = aws_subnet.dev-private-sub-01.id
  route_table_id = aws_route_table.dev-private-rt-01.id
}

resource "aws_eip" "dev-eip" {
  domain = "vpc"
  tags = {
    Name = "Dev-Cloud-EIP"
  }
}

resource "aws_nat_gateway" "dev-nat" {
  subnet_id = aws_subnet.dev-public-sub-01.id
  allocation_id = aws_eip.dev-eip.allocation_id
  tags = {
    Name = "Dev-Cloud-NAT"
  }
}

resource "aws_route" "dev-private-rt-01-route-01" {
  route_table_id = aws_route_table.dev-private-rt-01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.dev-nat.id 
}

resource "aws_security_group" "dev-public-sg" {
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Dev-Public-SG"
  }
}

resource "aws_security_group" "dev-private-sg" {
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.dev-public-sg.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Dev-Private-SG"
  }
}

resource "aws_instance" "dev-public-server" {
  count = var.public-instance-count
  ami = var.ami-id
  instance_type = "t2.micro"
  key_name = "Selva_Linux_April_2024"
  vpc_security_group_ids = [aws_security_group.dev-public-sg.id]
  subnet_id = aws_subnet.dev-public-sub-01.id

  root_block_device {
    volume_size = 12
  }

  tags = {
    Name = "Dev-Public-Server"
  }
}
  resource "aws_instance" "dev-private-server" {
  count = var.public-instance-count
  ami = var.ami-id
  instance_type = "t2.micro"
  key_name = "Selva_Linux_April_2024"
  vpc_security_group_ids = [aws_security_group.dev-private-sg.id]
  subnet_id = aws_subnet.dev-private-sub-01.id

  root_block_device {
    volume_size = 12
  }

  tags = {
    Name = "Dev-Private-Server"
  }
}