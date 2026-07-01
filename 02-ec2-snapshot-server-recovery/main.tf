terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "snapshot-recovery-vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "snapshot-recovery-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "snapshot-recovery-igw"
  }
}

# Route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "snapshot-recovery-public-rt"
  }
}

# Default route to internet
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate subnet with route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security group allowing HTTP access
resource "aws_security_group" "web_sg" {
  name        = "snapshot-recovery-web-sg"
  description = "Allow HTTP access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "snapshot-recovery-web-sg"
  }
}

# Original EC2 server
resource "aws_instance" "original_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl enable httpd
              systemctl start httpd

              cat <<HTML > /var/www/html/index.html
              <html>
              <head>
                <title>Original Server</title>
              </head>
              <body>
                <h1>Original EC2 Server</h1>
                <p>This server was created using Terraform.</p>
                <p>Project: Automated Snapshot and Server Recovery with IaC</p>
                <p>Region: Stocholm - eu-north-1a</p>
              </body>
              </html>
              HTML
              EOF

  tags = {
    Name = "original-snapshot-recovery-server"
  }
}

output "original_server_public_ip" {
  value = aws_instance.original_server.public_ip
}

output "original_server_url" {
  value = "http://${aws_instance.original_server.public_ip}"
}

#server back up

resource "aws_ami_from_instance" "server_backup" {
  name               = "server-backup-project-02"
  source_instance_id = aws_instance.original_server.id
 

  tags = {
    Name    = "server-backup-project-02"
    Project = "EC2 Snapshot Recovery"
    Role    = "Backup"
  }
}

resource "aws_instance" "recovered_server" {
  ami                         = aws_ami_from_instance.server_backup.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = {
    Name    = "recovered-server-project-02"
    Project = "EC2 Snapshot Recovery"
    Role    = "Recovered"
  }
}

output "backup_ami_id" {
  value = aws_ami_from_instance.server_backup.id
}

output "recovered_server_public_ip" {
  value = aws_instance.recovered_server.public_ip
}

output "recovered_server_url" {
  value = "http://${aws_instance.recovered_server.public_ip}"
}