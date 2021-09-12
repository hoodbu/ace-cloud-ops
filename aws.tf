##################################################################
# Data source to get AMI details
##################################################################
data "aws_ami" "ubuntu" {
  provider    = aws.west
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_ami" "ubuntu2" {
  provider    = aws.west2
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_ami" "amazon_linux" {
  provider    = aws.west
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }
  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

data "aws_ami" "amazon_linux_west2" {
  provider    = aws.west2
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }
  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

locals {
  bu1_frontend_user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname "BU1-Frontend"
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo echo 'ubuntu:${var.ace_password}' | /usr/sbin/chpasswd
sudo apt update -y
sudo apt upgrade -y
sudo apt-get -y install traceroute unzip build-essential git gcc hping3 apache2 net-tools
sudo apt autoremove
sudo /etc/init.d/ssh restart
sudo echo "<html><h1>Aviatrix is awesome</h1></html>" > /var/www/html/index.html 
EOF
}

locals {
  bu2_mobile_app_user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname "BU2-Mobile-App"
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo echo 'ubuntu:${var.ace_password}' | /usr/sbin/chpasswd
sudo apt update -y
sudo apt upgrade -y
sudo apt-get -y install traceroute unzip build-essential git gcc hping3 apache2 net-tools
sudo apt autoremove
sudo /etc/init.d/ssh restart
sudo echo "<html><h1>Aviatrix is awesome</h1></html>" > /var/www/html/index.html 
EOF
}

module "security_group_1" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "~> 3.0"
  name                = "security_group_spoke1"
  description         = "Security group for example usage with EC2 instance"
  vpc_id              = module.aws_spoke_1.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
  providers = {
    aws = aws.west
  }
}

module "security_group_2" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "~> 3.0"
  name                = "security_group_spoke2"
  description         = "Security group for example usage with EC2 instance"
  vpc_id              = module.aws_spoke_2.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
  providers = {
    aws = aws.west
  }
}

module "aws_spoke_ubu_1" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "2.21.0"
  instance_type               = var.aws_test_instance_size
  name                        = "${var.aws_spoke1_name}-ubu"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = var.EW1_ec2_key_name
  subnet_id                   = module.aws_spoke_1.vpc.public_subnets[0].subnet_id
  vpc_security_group_ids      = [module.security_group_1.this_security_group_id]
  associate_public_ip_address = true
  user_data_base64            = base64encode(local.bu1_frontend_user_data)
  providers = {
    aws = aws.west
  }
}

data "aws_network_interface" "aws-spoke1-ubu-ni" {
  provider = aws.west
  id       = module.aws_spoke_ubu_1.primary_network_interface_id
}

module "aws_spoke_ubu_2" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "2.21.0"
  instance_type               = var.aws_test_instance_size
  name                        = "${var.aws_spoke2_name}-ubu"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = var.EW1_ec2_key_name
  subnet_id                   = module.aws_spoke_2.vpc.public_subnets[0].subnet_id
  vpc_security_group_ids      = [module.security_group_2.this_security_group_id]
  associate_public_ip_address = true
  user_data_base64            = base64encode(local.bu2_mobile_app_user_data)
  providers = {
    aws = aws.west
  }
}

data "aws_network_interface" "aws-spoke2-ubu-ni" {
  provider = aws.west
  id       = module.aws_spoke_ubu_2.primary_network_interface_id
}

output "aws_spoke1_ubu_public_ip" {
  value = module.aws_spoke_ubu_1.public_ip
}

output "aws_spoke1_ubu_private_ip" {
  value = data.aws_network_interface.aws-spoke1-ubu-ni.private_ip
}

output "aws_spoke2_ubu_public_ip" {
  value = module.aws_spoke_ubu_2.public_ip
}

output "aws_spoke2_ubu_private_ip" {
  value = data.aws_network_interface.aws-spoke2-ubu-ni.private_ip
}
