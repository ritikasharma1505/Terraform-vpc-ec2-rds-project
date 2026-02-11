# ami - ubuntu 24.04

data "aws_ssm_parameter" "ubuntu_2404" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

# EC2 security group

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-ssh-sg"
  description = "Allow SSH from trusted IP"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access from trusted IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-ssh-sg"
  }
}

# EC2 instance 

resource "aws_instance" "web" {
  ami = data.aws_ssm_parameter.ubuntu_2404.value
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  key_name = var.key_name
  vpc_security_group_ids  = [aws_security_group.ec2_sg.id]

# User data installs mysql client on first time ec2 creation -  for ubuntu 
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y mysql-client
              echo "MySQL client installed successfully!" > /home/ubuntu/mysql-installed.log
            EOF

  tags = {
    Name = "web-instance"
  }
}
