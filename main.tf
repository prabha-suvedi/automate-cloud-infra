provider "aws" {
  region = "eu-north-1" 
}


resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16" # VPC CIDR block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MainVPC"
  }
}


resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "MainInternetGateway"
  }
}


resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  # Route to the internet via the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "MainRouteTable"
  }
}


resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-north-1a"  
  map_public_ip_on_launch = true
  tags = {
    Name = "Main Subnet"
  }
}


resource "aws_route_table_association" "main_subnet_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}


resource "aws_security_group" "example_sg" {
  name        = "example-security-group"
  description = "Allow HTTP, HTTPS, and SSH traffic"
  vpc_id      = aws_vpc.main_vpc.id 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 

  ingress {
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
    Name = "ExampleSecurityGroup"
  }
}


resource "aws_network_interface" "example_eni" {
  subnet_id       = aws_subnet.main_subnet.id          
  private_ips     = ["10.0.1.10"]                      
  security_groups = [aws_security_group.example_sg.id] 
  tags = {
    Name = "ExampleNetworkInterface"
  }
}


resource "aws_eip" "example_eip" {
  domain = "vpc" 

  tags = {
    Name = "ExampleElasticIP"
  }
}



resource "aws_network_interface_attachment" "eni_attachment" {
  instance_id          = aws_instance.example_instance.id 
  network_interface_id = aws_network_interface.example_eni.id
  device_index         = 0
}


resource "aws_instance" "example_instance" {
  ami           = "ami-02df5cb5ad97983ba" 
  instance_type = "t3.micro"

  
  network_interface {
    network_interface_id = aws_network_interface.example_eni.id
    device_index         = 1 
  }

  tags = {
    Name = "ExampleInstance"
  }
}


variable "aws_access_key" {
  description = "AKIA2OAJUD2C5TUHHGX5"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "ABc0x24EbgTPLkHP/MoBQUuEQKMex4g5HXITTi2A"
  type        = string
  sensitive   = true
}
