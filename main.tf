terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}



provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "my_server" {
  instance_type        = "t3.micro"
  ami                  = "ami-07a00cf47dbbc844c"
  key_name             = "project-key"
  availability_zone    = "ap-south-1b"
  hibernation          = true

  root_block_device {
    encrypted   = true
    volume_size = 10
  }

  tags = {
    Name = "infra"
  }

  ebs_block_device {
    device_name             = "/dev/sdh"
    volume_size             = 8
    encrypted               = true
    delete_on_termination   = true
  }

  provisioner "local-exec" {
    command = <<EOT
      sudo sleep 120
      sudo ssh-keygen -R ${self.public_ip}
      sudo ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${self.public_ip}, playbook.yaml -u ec2-user --private-key /home/ubuntu/project-key.pem 
    EOT
  }
}

