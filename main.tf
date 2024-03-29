# Provider Configuration
provider "aws" {
	alias = "ap-south-1"
	region = "ap-south-1"
}

provider "aws" {
	alias = "us-east-1"
	region = "us-east-1"
}

output "instanceip1" {
  value = aws_instance.instance1vpc01.public_ip
}

output "instanceip2" {
  value = aws_instance.instance2vpc01.public_ip
}

output "instanceip3" {
  value = aws_instance.instance1vpc02.public_ip
}

# variable "cidr1" {
#    default = "10.0.0.0/16"
# }

# variable "cidr2" {
#   default = "192.168.0.0/16"
# }

# VPC 1 Configuration
resource "aws_vpc" "vpc1" {
  provider = aws.ap-south-1
  cidr_block =  "10.0.0.0/16" # Update with your desired CIDR block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-01"
  }
}


# 2 Subnets for VPC1 
resource "aws_subnet" "subnet01vpc01" {
  provider = aws.ap-south-1
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"
  availability_zone  = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet01-VPC01"
  }
}

resource "aws_subnet" "subnet02vpc01" {
  provider = aws.ap-south-1
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.2.0/24"
  availability_zone  = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet02-VPC01"
  }
}

# Gateways for VPC1
resource "aws_internet_gateway" "vpc01igw" {
  provider = aws.ap-south-1
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "vpc01igw"
  }
}

#Route Table 
resource "aws_route_table" "routevpc01" {
  provider = aws.ap-south-1
  vpc_id = aws_vpc.vpc1.id
  depends_on = [ aws_vpc_peering_connection.peering ]

  tags = {
    Name = "Route-VPC01"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc01igw.id
  }
  route {
    cidr_block = "192.168.0.0/16"
    gateway_id = aws_vpc_peering_connection.peering.id
  }
}

# Add the subnet association to the route tables
resource "aws_route_table_association" "sub1vpc1" {
    provider = aws.ap-south-1
    subnet_id = aws_subnet.subnet01vpc01.id
    route_table_id = aws_route_table.routevpc01.id
}

resource "aws_route_table_association" "sub2vpc1" {
    provider = aws.ap-south-1
    subnet_id = aws_subnet.subnet02vpc01.id
    route_table_id = aws_route_table.routevpc01.id
}

#Security group vpc1
resource "aws_security_group" "sgvpc01" {
  provider = aws.ap-south-1
  name = "web"
  vpc_id = aws_vpc.vpc1.id


  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "sgvpc01"
  }
}

# VPC 2 Configuration
resource "aws_vpc" "vpc2" {
  provider = aws.us-east-1
  cidr_block = "192.168.0.0/16" # Update with your desired CIDR block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-02"
  }
}

# 1 subnet for VPC2
resource "aws_subnet" "subnet01vpc02" {
  provider = aws.us-east-1
  vpc_id     = aws_vpc.vpc2.id
  cidr_block = "192.168.1.0/24"
  availability_zone  = "us-east-1d"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet01-VPC02"
  }
}

# internet gateway vpc2
resource "aws_internet_gateway" "vpc02igw" {
  provider = aws.us-east-1
  vpc_id = aws_vpc.vpc2.id
  tags = {
    Name = "vpc02igw"
  }
}

#route table vpc2
resource "aws_route_table" "routevpc02" {
  provider = aws.us-east-1
  vpc_id = aws_vpc.vpc2.id
  depends_on = [ aws_vpc_peering_connection.peering ]

  tags = {
    Name = "Route-VPC02"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc02igw.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = aws_vpc_peering_connection.peering.id
  }
}

#subnet association vpc2
resource "aws_route_table_association" "sub1vpc2" {
    provider = aws.us-east-1
    subnet_id = aws_subnet.subnet01vpc02.id
    route_table_id = aws_route_table.routevpc02.id
}

#Security groups vpc2
resource "aws_security_group" "sgvpc02" {
  provider = aws.us-east-1
  name = "sgvpc02"
  vpc_id = aws_vpc.vpc2.id


  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "sgvpc02"
  }
}

#Generate keypair for instances
resource "aws_key_pair" "keypairmum" {
  provider = aws.ap-south-1
  key_name = "terraform-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD6gmxxd0+6AV58VKjIIKz++A0tv5EM+MsS0vk9SfxfB/OiW7jbbLxq/Usvzl9HazkSqWWP7GyasijD3TmcNU65ixyO+xQdiyyILbF/CXtlxu+9tCudAc5f8pQyMQ0Pj9lvA1Dn1YSQeAmfqRMu+AYQhu+Adw4815p39RLKkU3LY0RACs4lfRwxWc95yP/SlhwDPfA+kVMh8D2uzOUoKpBn20k/nTgbysMDf5Ad3qqq2Ev3go6H2hWTKb6v9keWTS6hSr51MUPdEDZ5ATWj8kbu3MYb9qino1d6XV4s/Vh3gZBAQvEkgnFI1fI3Eqlvn4bvp+qa51qu+/JMFGFwI/UnBYZ/hjRkowLnyOlm7rJgFh97v04OK6dvMIhYCjoU0RXYehXMeKr7/okQDBALFroCZ7GO2Wcw+kndx0GitMSB/xXE6WLhUsx4YgTx52nnbR+KBKalYKztrAuZAobN2ItrFOociVhs4WATc6GNlzoriGtwfd4kCC3t29IBnyQIiTU= ubuntu@ip-172-31-95-172"
}

resource "aws_key_pair" "keypairus" {
  provider = aws.us-east-1
  key_name = "terraform-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD6gmxxd0+6AV58VKjIIKz++A0tv5EM+MsS0vk9SfxfB/OiW7jbbLxq/Usvzl9HazkSqWWP7GyasijD3TmcNU65ixyO+xQdiyyILbF/CXtlxu+9tCudAc5f8pQyMQ0Pj9lvA1Dn1YSQeAmfqRMu+AYQhu+Adw4815p39RLKkU3LY0RACs4lfRwxWc95yP/SlhwDPfA+kVMh8D2uzOUoKpBn20k/nTgbysMDf5Ad3qqq2Ev3go6H2hWTKb6v9keWTS6hSr51MUPdEDZ5ATWj8kbu3MYb9qino1d6XV4s/Vh3gZBAQvEkgnFI1fI3Eqlvn4bvp+qa51qu+/JMFGFwI/UnBYZ/hjRkowLnyOlm7rJgFh97v04OK6dvMIhYCjoU0RXYehXMeKr7/okQDBALFroCZ7GO2Wcw+kndx0GitMSB/xXE6WLhUsx4YgTx52nnbR+KBKalYKztrAuZAobN2ItrFOociVhs4WATc6GNlzoriGtwfd4kCC3t29IBnyQIiTU= ubuntu@ip-172-31-95-172"
}

# VPC Peering Connection Requestors side
resource "aws_vpc_peering_connection" "peering" {
  provider = aws.us-east-1
  #peer_owner_id = var.peer_owner_id
  peer_vpc_id   = aws_vpc.vpc1.id
  vpc_id        = aws_vpc.vpc2.id
  auto_accept   = false
  peer_region = "ap-south-1"
  depends_on = [
    aws_vpc.vpc1,
    aws_vpc.vpc2
  ]

  tags = {
    Name = "VPC01-VPC02"
    Side = "Requestor"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.ap-south-1
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  auto_accept               = true

  tags = {
    Name = "VPC01-VPC02"
    Side = "Accepter"
  }
}


# Create 3 instances in each subnets
resource "aws_instance" "instance1vpc01" {
  provider = aws.ap-south-1
  ami = "ami-03bb6d83c60fc5f7c"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet01vpc01.id
  key_name = aws_key_pair.keypairmum.key_name
  vpc_security_group_ids = [aws_security_group.sgvpc01.id]

  # connection {
  #   type = "ssh"
  #   user = "ubuntu"
  #   private_key = "file(~/.ssh/id_rsa)"
  #   host = self.public_ip
  # }

  # provisioner "remote-exec" {
  #   inline = [ 
  #       "sudo apt update",
  #       "sudo apt install apache2 -y",
  #       "echo 'Welcome to Mumbai VPC01 in AP-SOUTH-1A AZ' | sudo tee /var/www/html/index.html",
  #       "sudo systemctl restart apache2"
  #   ]
  #}
  tags = {
    Name = "instance1vpc01"
  }
}


resource "aws_instance" "instance2vpc01" {
  provider = aws.ap-south-1
  ami = "ami-03bb6d83c60fc5f7c"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet02vpc01.id
  key_name = aws_key_pair.keypairmum.key_name
  vpc_security_group_ids = [aws_security_group.sgvpc01.id]

  # connection {
  #   type = "ssh"
  #   user = "ubuntu"
  #   private_key = "file(~/.ssh/id_rsa)"
  #   host = self.public_ip
  # }
  # provisioner "remote-exec" {
  #   inline = [ 
  #       "sudo apt update",
  #       "sudo apt install apache2 -y",
  #       "echo 'Welcome to Mumbai VPC01 in AP-SOUTH-1B AZ' | sudo tee /var/www/html/index.html",
  #       "sudo systemctl restart apache2"
  #   ]
  # }

  tags = {
    Name = "instance2vpc01"
  }
}

resource "aws_instance" "instance1vpc02" {
  provider = aws.us-east-1
  ami = "ami-07d9b9ddc6cd8dd30"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet01vpc02.id
  key_name = aws_key_pair.keypairus.key_name
  vpc_security_group_ids = [aws_security_group.sgvpc02.id]

  # connection {
  #   type = "ssh"
  #   user = "ubuntu"
  #   private_key = "file(~/.ssh/id_rsa)"
  #   host = self.public_ip
  # }
  # provisioner "remote-exec" {
  #   inline = [ 
  #       "sudo apt update",
  #       "sudo apt install apache2 -y",
  #       "echo 'Welcome to Virginia VPC02 in US-EAST-1D AZ' | sudo tee /var/www/html/index.html",
  #       "sudo systemctl restart apache2"
  #   ]
  # }
  tags = {
    Name = "instance1vpc02"
  }
}
