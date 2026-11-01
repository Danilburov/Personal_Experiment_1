data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

#SSH key pair
#AWS gets the public half, Ansible gets the private half
resource "tls_private_key" "ansible" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "lab" {
  key_name   = "jenkins-lab"
  public_key = tls_private_key.ansible.public_key_openssh
}

resource "aws_instance" "server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k3s.id]
  key_name               = aws_key_pair.lab.key_name

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = { Name = "k3s-server" }
  lifecycle {
    ignore_changes = [ami]
  }
}