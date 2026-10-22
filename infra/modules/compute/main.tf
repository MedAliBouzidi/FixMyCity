data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "aws_iam_instance_profile" "lab_profile" {
  name = "LabInstanceProfile"
}

# 1. Initial Frontend Instance (Placed in Public Subnet 1 per diagram)
resource "aws_instance" "frontend_node" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_1_id
  vpc_security_group_ids = [var.sg_app_frontend_id]
  iam_instance_profile   = data.aws_iam_instance_profile.lab_profile.name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker
              systemctl enable --now docker
              usermod -aG docker ec2-user

              # Probe container listening on port 3000
              docker run -d --name fixmycity-frontend-l3 -p 3000:5678 hashicorp/http-echo \
                -text='{"status":"UP","tier":"frontend","port":3000}'
              EOF

  tags = {
    Name = "${var.group_prefix}-ec2-frontend-l3"
  }
}

# 2. Initial Backend Instance (Placed in Private Backend Subnet 1 per diagram)
resource "aws_instance" "backend_node" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = var.private_backend_1_id
  vpc_security_group_ids = [var.sg_app_backend_id]
  iam_instance_profile   = data.aws_iam_instance_profile.lab_profile.name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker
              systemctl enable --now docker
              usermod -aG docker ec2-user

              # Probe container listening on port 4000
              docker run -d --name fixmycity-backend-l3 -p 4000:5678 hashicorp/http-echo \
                -text='{"status":"UP","tier":"backend","port":4000}'
              EOF

  tags = {
    Name = "${var.group_prefix}-ec2-backend-l3"
  }

  depends_on = [var.nat_gateway_id]
}