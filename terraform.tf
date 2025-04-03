provider "aws" {
  region = "eu-north-1"
}

# Adding new part
# Fetch the latest Ubuntu AMI ID dynamically
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create a new EC2 instance
resource "aws_instance" "new_note_app_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = "your-key-pair"   # Replace with your AWS key pair
  vpc_security_group_ids = [aws_security_group.note-app-sg.id]

  tags = {
    Name = "NoteAppInstance"
  }
}

#End of the new part

data "aws_instance" "Note-Application" {
  instance_id = "i-0e5df4ddbf9a23cb6"
}

resource "aws_security_group" "note-app-sg" {
  name        = "note-app-sg"
  description = "Security group for Note application"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins access
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Backend API access
  ingress {
    from_port   = 5050
    to_port     = 5050
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Frontend access
  ingress {
    from_port   = 3000
    to_port     = 3000
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

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.note-app-sg.id
  network_interface_id = data.aws_instance.Note-Application.network_interface_id
}

output "instance_public_dns" {
  value = data.aws_instance.Note-Application.public_dns
}