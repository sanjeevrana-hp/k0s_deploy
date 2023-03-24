###### Generating Random username/password ##########
# Creating two random password for username and Password
resource "random_pet" "username" {
  length = 2
}
resource "random_string" "password" {
  length  = 20
  special = false
}
# Creating a local variable for generating randomness
locals {
  tstmp = formatdate("DD-MMM-YYYY:hh-mm", timestamp())
}

######## CREATING A SECURITY GROUP #########

resource "aws_security_group" "allow-all-security-group" {
  name        = "${var.name}-${random_pet.username.id}-SecurityGroup"
  description = "Allow everything for an ephemeral cluster"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name           = "${var.name}-SecurityGroup"
    DateOfCreation = local.tstmp
    resourceType   = "Security Group"
    resourceOwner  = "${var.name}"
  }
}

####### CREATING THE KEY PAIR  #######
# RSA key of size 4096 bits
resource "tls_private_key" "rsa-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "KeyPair" {
  key_name   = "${var.name}-${random_pet.username.id}-KeyPair"
  public_key = tls_private_key.rsa-key.public_key_openssh
  tags = {
    DateOfCreation = local.tstmp
  }
}

resource "local_file" "KeyPair_File" {
  content         = tls_private_key.rsa-key.private_key_pem
  filename        = "mykey-pair"
  file_permission = "0400"
}

####### CREATING THE EC2 Compute ###########

resource "aws_instance" "k0s_controller" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type_controller
  count           = var.controller_count
  key_name        = "${var.name}-${random_pet.username.id}-KeyPair"
  security_groups = ["${aws_security_group.allow-all-security-group.name}"]
  root_block_device {
    volume_size           = "30"
    delete_on_termination = "true"
  }
  user_data = <<EOF
#!/bin/bash
cd /var/tmp/
apt-get update -y
apt-get install wget
EOF
  tags = {
    Name           = "controller_${count.index}"
    Type           = "controller"
    DateOfCreation = local.tstmp
  }
}


resource "aws_instance" "k0s_worker" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type_worker
  count           = var.worker_count
  key_name        = "${var.name}-${random_pet.username.id}-KeyPair"
  security_groups = ["${aws_security_group.allow-all-security-group.name}"]
  root_block_device {
    volume_size           = "30"
    delete_on_termination = "true"
  }
  user_data = <<EOF
#!/bin/bash
cd /var/tmp/
apt-get update -y
apt-get install wget
EOF
  tags = {
    Name           = "worker_${count.index}"
    Type           = "worker"
    DateOfCreation = local.tstmp
  }
}

locals {
  k0s_tmpl = {
    apiVersion = "k0sctl.k0sproject.io/v1beta1"
    kind       = "cluster"
    spec = {
      hosts = [
        for host in concat(aws_instance.k0s_controller, aws_instance.k0s_worker) : {
          ssh = {
            address = host.public_ip
            user    = "ubuntu"
            keyPath = "mykey-pair"
          }
          role = host.tags["Type"]
        }
      ]
      k0s = {
        version = "1.26.2+k0s.1"
      }
    }
  }
}

output "k0s_cluster" {
  value = yamlencode(local.k0s_tmpl)

}
