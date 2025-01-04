provider "aws" {
  region = "eu-north-1" # Specify the AWS region
  # Do not hardcode credentials. Use environment variables or IAM roles for access
}

# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16" # VPC CIDR block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MainVPC"
  }
}

# Create an Internet Gateway (IGW) and attach it to the VPC
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "MainInternetGateway"
  }
}

# Create a custom route table for the VPC
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  # Route to the internet via the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0" # Allow all traffic to the internet
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "MainRouteTable"
  }
}

# Create a Subnet and associate it with the route table
resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-north-1a"  # Change this to a valid AZ
  map_public_ip_on_launch = true
  tags = {
    Name = "Main Subnet"
  }
}

# Associate the subnet with the route table
resource "aws_route_table_association" "main_subnet_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

# Create a Security Group
resource "aws_security_group" "example_sg" {
  name        = "example-security-group"
  description = "Allow HTTP, HTTPS, and SSH traffic"
  vpc_id      = aws_vpc.main_vpc.id # Reference the created VPC

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from any IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from any IP
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS from any IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ExampleSecurityGroup"
  }
}

# Create an Elastic Network Interface (ENI) in the subnet
resource "aws_network_interface" "example_eni" {
  subnet_id       = aws_subnet.main_subnet.id          # Reference to the subnet where this ENI will be created
  private_ips     = ["10.0.1.10"]                      # Assign a private IP address within the subnet CIDR range
  security_groups = [aws_security_group.example_sg.id] # Attach the security group

  tags = {
    Name = "ExampleNetworkInterface"
  }
}

# Allocate an Elastic IP
resource "aws_eip" "example_eip" {
  domain = "vpc" # This is the correct way to specify that the EIP is for a VPC

  tags = {
    Name = "ExampleElasticIP"
  }
}


# Attach the Elastic IP to the ENI
resource "aws_network_interface_attachment" "eni_attachment" {
  instance_id          = aws_instance.example_instance.id # Use instance_id to ensure attachment
  network_interface_id = aws_network_interface.example_eni.id
  device_index         = 0
}

# Create an EC2 instance and attach the ENI
resource "aws_instance" "example_instance" {
  ami           = "ami-02df5cb5ad97983ba" # Replace with a valid AMI ID
  instance_type = "t3.micro"

  # Attach the ENI to the EC2 instance
  network_interface {
    network_interface_id = aws_network_interface.example_eni.id
    device_index         = 1 # Always 0 for the primary network interface
  }

  tags = {
    Name = "ExampleInstance"
  }
}

# Variables for AWS Credentials (ensure this is securely handled)
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
