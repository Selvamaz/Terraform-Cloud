# Creates VPC with CIDR
resource "aws_vpc" "dev-vpc-tf-cloud" {
  cidr_block   = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Dev-Cloud-VPC"
  }
}

# Create Public Subnet 01
resource "aws_subnet" "dev-public-sub-01"{
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id
  cidr_block = var.public-sub-01-cidr
  availability_zone = var.region-zone1
  map_public_ip_on_launch = "true"
  tags = {
    Name = "Dev-Cloud-Subnet-Public-01"
  }
  depends_on = [ aws_vpc.dev-vpc-tf-cloud ]
}

# Create Public Subnet 02
resource "aws_subnet" "dev-public-sub-02"{
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id
  cidr_block = var.public-sub-02-cidr
  availability_zone = var.region-zone2
  map_public_ip_on_launch = "true"
  tags = {
    Name = "Dev-Cloud-Subnet-Public-02"
  }
  depends_on = [ aws_vpc.dev-vpc-tf-cloud ]
}

# Create Private Subnet 01
resource "aws_subnet" "dev-private-sub-01"{
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id
  cidr_block = var.private-sub-01-cidr
  availability_zone = var.region-zone1
  tags = {
    Name = "Dev-Cloud-Subnet-Private-01"
  }
  depends_on = [ aws_vpc.dev-vpc-tf-cloud ]
}

# Create Private Subnet 02
resource "aws_subnet" "dev-private-sub-02"{
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id
  cidr_block = var.private-sub-02-cidr
  availability_zone = var.region-zone2
  tags = {
    Name = "Dev-Cloud-Subnet-Private-02"
  }
  depends_on = [ aws_vpc.dev-vpc-tf-cloud ]
}

# Create Internet Gateway for Public Subnets
resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id
  tags = {
    Name = "Dev-Cloud-IGW"
  }
  depends_on = [ aws_vpc.dev-vpc-tf-cloud ]
}

# Create Route Table for Public Subnet 01
resource "aws_route_table" "dev-public-rt-01" {
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id
  tags = {
    Name = "Dev-Cloud-RT-01-Public"
  }
  depends_on = [ aws_subnet.dev-public-sub-01 ]
}

# Create Route Table for Public Subnet 02
resource "aws_route_table" "dev-public-rt-02" {
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id
  tags = {
    Name = "Dev-Cloud-RT-02-Public"
  }
  depends_on = [ aws_subnet.dev-public-sub-02 ]
}

# Create Route Table for Private Subnet 01
resource "aws_route_table" "dev-private-rt-01" {
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id
  tags = {
    Name = "Dev-Cloud-RT-01-Private"
  }
  depends_on = [ aws_subnet.dev-private-sub-01 ]
}

# Create Route Table for Private Subnet 02
resource "aws_route_table" "dev-private-rt-02" {
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id
  tags = {
    Name = "Dev-Cloud-RT-02-Private"
  }
  depends_on = [ aws_subnet.dev-private-sub-02 ]
}

# Create Subnet Association for Public Subnet 01
resource "aws_route_table_association" "dev-rt-01-associate-pub-01" {
  subnet_id = aws_subnet.dev-public-sub-01.id
  route_table_id = aws_route_table.dev-public-rt-01.id
  depends_on = [ aws_route_table.dev-public-rt-01 ]
}

# Create Subnet Association for Public Subnet 02
resource "aws_route_table_association" "dev-rt-02-associate-pub-02" {
  subnet_id = aws_subnet.dev-public-sub-02.id
  route_table_id = aws_route_table.dev-public-rt-02.id
  depends_on = [ aws_route_table.dev-public-rt-02 ]
}

# Internet Gateway Connection with Public Route Table 01
resource "aws_route" "dev-public-rt-01-route-01" {
  depends_on = [aws_internet_gateway.dev-igw, aws_route_table.dev-public-rt-01]
  route_table_id = aws_route_table.dev-public-rt-01.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.dev-igw.id
}

# Internet Gateway Connection with Public Route Table 02
resource "aws_route" "dev-public-rt-02-route-02" {
  depends_on = [aws_internet_gateway.dev-igw, aws_route_table.dev-public-rt-02]
  route_table_id = aws_route_table.dev-public-rt-02.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.dev-igw.id
}

# Create Subnet Association for Private Subnet 01
resource "aws_route_table_association" "dev-rt-01-associate-pvt" {
  subnet_id = aws_subnet.dev-private-sub-01.id
  route_table_id = aws_route_table.dev-private-rt-01.id
  depends_on = [ aws_route_table.dev-private-rt-01 ]
}

# Create Subnet Association for Private Subnet 02
resource "aws_route_table_association" "dev-rt-02-associate-pvt" {
  subnet_id = aws_subnet.dev-private-sub-02.id
  route_table_id = aws_route_table.dev-private-rt-01.id
  depends_on = [ aws_route_table.dev-private-rt-02 ]
}

# Elastic IP For Private Subnet 01
resource "aws_eip" "dev-eip-01" {
  domain = "vpc"
  tags = {
    Name = "Dev-Cloud-EIP-01"
  }
}

# NAT Gateway Connection For Private Subnet 01
resource "aws_nat_gateway" "dev-nat-01" {
  subnet_id = aws_subnet.dev-public-sub-01.id
  allocation_id = aws_eip.dev-eip-01.allocation_id
  tags = {
    Name = "Dev-Cloud-NAT-01"
  }
  depends_on = [ aws_subnet.dev-public-sub-01, aws_eip.dev-eip-01 ]
}

# Attaching EIP & NAT Gateway for Private Subnet 01
resource "aws_route" "dev-private-rt-01-route-01" {
  route_table_id = aws_route_table.dev-private-rt-01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.dev-nat-01.id 
  depends_on = [aws_route_table.dev-private-rt-01, aws_nat_gateway.dev-nat-01 ]
}

# Elastic IP For Private Subnet 02
resource "aws_eip" "dev-eip-02" {
  domain = "vpc"
  tags = {
    Name = "Dev-Cloud-EIP-02"
  }
}

# NAT Gateway Connection For Private Subnet 02
resource "aws_nat_gateway" "dev-nat-02" {
  subnet_id = aws_subnet.dev-public-sub-02.id
  allocation_id = aws_eip.dev-eip-02.allocation_id
  tags = {
    Name = "Dev-Cloud-NAT-02"
  }
  depends_on = [ aws_subnet.dev-public-sub-02, aws_eip.dev-eip-02 ]
}

# Attaching EIP & NAT Gateway for Private Subnet 02
resource "aws_route" "dev-private-rt-02-route-02" {
  route_table_id = aws_route_table.dev-private-rt-02.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.dev-nat-02.id 
  depends_on = [aws_route_table.dev-private-rt-02, aws_nat_gateway.dev-nat-02 ]
}

# Public Security Group
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

  ingress {
    from_port = 5432
    to_port = 5432
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

# Private Security Group
resource "aws_security_group" "dev-private-sg" {
  vpc_id = aws_vpc.dev-vpc-tf-cloud.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.dev-public-sg.id]
  }
  
  ingress {
    from_port = 5432
    to_port = 5432
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
    Name = "Dev-Private-SG"
  }
}

# Public Subnet 01 Instances
resource "aws_instance" "dev-public-server-subnet-01" {
  count = 1
  ami = var.ami-id
  instance_type = var.instance-type
  key_name = var.instance_key
  vpc_security_group_ids = [aws_security_group.dev-public-sg.id]
  subnet_id = aws_subnet.dev-public-sub-01.id

  # Specify the user data script
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              EOF

  root_block_device {
    volume_size = 12
  }

  # Provisioner to copy files
  provisioner "file" {
    source      = "/Users/selva/Documents/Go Nations/Website/"  # Replace with the path to your local file or directory
    destination = "/home/ubuntu/"    # Destination path on the remote instance
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("key.pem")  # Replace with the path to your private key
      host        = self.public_ip
    }
  }
  
  # Provisioner to copy files to httpd server
  provisioner "remote-exec" {
    inline = [
      "sleep 100",  # Sleep for 200 seconds
      "sudo chown ubuntu:ubuntu -R /var/www/html/",
      "sudo cp -r /home/ubuntu/* /var/www/html/",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("key.pem")  # Replace with the path to your private key
      host        = self.public_ip
    }
  }

  tags = {
    Name = "Dev-Public-Server-Subnet-01"
  }
}

# Public Subnet 02 Instances
resource "aws_instance" "dev-public-server-subnet-02" {
  count = 1
  ami = var.ami-id
  instance_type = var.instance-type
  key_name = var.instance_key
  vpc_security_group_ids = [aws_security_group.dev-public-sg.id]
  subnet_id = aws_subnet.dev-public-sub-02.id

  # Specify the user data script
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              EOF

  root_block_device {
    volume_size = 12
  }

  # Provisioner to copy files
  provisioner "file" {
    source      = "/Users/selva/Documents/Go Nations/Website/"  # Replace with the path to your local file or directory
    destination = "/home/ubuntu/"    # Destination path on the remote instance
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("key.pem")  # Replace with the path to your private key
      host        = self.public_ip
    }
  }
  
  # Provisioner to copy files to httpd server
  provisioner "remote-exec" {
    inline = [
      "sleep 100",  # Sleep for 200 seconds
      "sudo chown ubuntu:ubuntu -R /var/www/html/",
      "sudo cp -r /home/ubuntu/* /var/www/html/",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("key.pem")  # Replace with the path to your private key
      host        = self.public_ip
    }
  }

  tags = {
    Name = "Dev-Public-Server-Subnet-02"
  }
}

# Private Subnet 01 Instances
resource "aws_instance" "dev-private-server-subnet-01" {
  count = 1
  ami = var.ami-id
  instance_type = var.instance-type
  key_name = var.instance_key
  vpc_security_group_ids = [aws_security_group.dev-private-sg.id]
  subnet_id = aws_subnet.dev-private-sub-01.id

  # Specify the user data script
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y postgresql postgresql-contrib
              sudo systemctl start postgresql
              sudo systemctl enable postgresql
              EOF

  root_block_device {
    volume_size = 12
  }

  tags = {
    Name = "Dev-Private-Server-Subnet-01"
  }
  depends_on = [ aws_route_table_association.dev-rt-01-associate-pvt, aws_db_instance.dev-db-server ]
}

# Private Subnet 02 Instances
resource "aws_instance" "dev-private-server-subnet-02" {
  count = 1
  ami = var.ami-id
  instance_type = var.instance-type
  key_name = var.instance_key
  vpc_security_group_ids = [aws_security_group.dev-private-sg.id]
  subnet_id = aws_subnet.dev-private-sub-02.id

  # Specify the user data script
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y postgresql postgresql-contrib
              sudo systemctl start postgresql
              sudo systemctl enable postgresql
              EOF

  root_block_device {
    volume_size = 12
  }

  tags = {
    Name = "Dev-Private-Server-Subnet-02"
  }
  depends_on = [ aws_route_table_association.dev-rt-02-associate-pvt, aws_db_instance.dev-db-server ]
}

