provider "aws" {
  region = "eu-north-1"
}

# Security Group
resource "aws_security_group" "note_app_sg" {
  name        = "launch-wizard-6"
  description = "Security group for Note App"
  vpc_id      = "vpc-09a69e5ab6c9a6295"

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Fetch the first subnet from the VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = ["vpc-09a69e5ab6c9a6295"]
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami                    = "ami-0c1ac8a41498c1a9c"  # Ubuntu AMI
  instance_type          = "t3.micro"
  key_name               = "Note-App"
  subnet_id              = data.aws_subnets.default.ids[0] # Use the first available subnet
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.note_app_sg.id]

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
    iops                  = 3000
    throughput            = 125
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name = "Web-Server"
  }
}

output "instance_public_dns" {
  value = aws_instance.web_server.public_dns
}
