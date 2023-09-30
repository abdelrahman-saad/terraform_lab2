resource "aws_instance" "bastion" {
  ami           = var.image_id 
  instance_type = var.instance_type
  subnet_id     = module.network_module.public_subnets[0].id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ssh_access.id]
  tags = {
    Name = "public ec2"
  }
  key_name               = aws_key_pair.my-key-pair1.id
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > inventory"
  }
  user_data = <<-EOF
                #!/bin/bash
                echo '${tls_private_key.my-key.private_key_pem}' > /home/ubuntu/private_key.pem
                chmod 400 private_key.pem
                EOF
}

resource "aws_instance" "application" {
  ami           = var.image_id
  instance_type = var.instance_type
  subnet_id     = module.network_module.private_subnets[0].id
  
  vpc_security_group_ids = [aws_security_group.ssh-port-3000.id]
  key_name      = aws_key_pair.my-key-pair1.id
  tags = {
    Name = "private ec2"
  }
}

resource "tls_private_key" "my-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my-key-pair1" {
  key_name   = "my-key-pair1"
  public_key = tls_private_key.my-key.public_key_openssh
}

resource "local_file" "my-key" {
  content  = tls_private_key.my-key.private_key_pem
  filename = "my-pr-key-pair.pem"
}