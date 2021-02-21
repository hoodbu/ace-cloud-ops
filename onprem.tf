// AWS Marketplace Opt-in Required - https://aws.amazon.com/marketplace/pp?sku=9fmjj3b9hombuy4jawab1i13i

locals {
  onprem_user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname "Call-Center"
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo echo 'ubuntu:${var.ace_password}' | /usr/sbin/chpasswd
sudo apt update -y
sudo apt upgrade -y
sudo apt-get -y install traceroute unzip build-essential git gcc iperf3 apache2 net-tools
sudo apt autoremove
sudo /etc/init.d/ssh restart
sudo echo "<html><h1>Aviatrix is awesome</h1></html>" > /var/www/html/index.html 
EOF
}

module "ace-onprem-partner1" {
  providers      = { aws = aws.west2 }
  source         = "terraform-aws-modules/vpc/aws"
  name           = "ace-onprem-partner1"
  cidr           = "172.16.211.0/24"
  azs            = ["eu-west-2a"]
  public_subnets = ["172.16.211.0/24"]

  tags = {
    Terraform   = "true"
    Environment = "ACE"
  }
}

resource "aws_security_group" "ace-onprem-partner1-sg" {
  provider = aws.west2
  name     = "ace-onprem-partner1-sg"
  vpc_id   = module.ace-onprem-partner1.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]   
  }
  tags = {
    Name = "ace-onprem-partner1-sg"
  }
}

resource "aws_instance" "ace-onprem-cisco-csr" {
  provider                    = aws.west2
  # Find an AMI by deploying manually from the Console first
  ami                         = "ami-05fecfb63c095734c"
  instance_type               = "t2.medium"
  subnet_id                   = module.ace-onprem-partner1.public_subnets[0]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = aws_key_pair.aws_west2_key.key_name
  vpc_security_group_ids      = [aws_security_group.ace-onprem-partner1-sg.id]
  user_data = <<EOF
    ios-config-100 = "username admin privilege 15 password ${var.ace_password}"
    ios-config-104 = "hostname OnPrem-Partner1"
    ios-config-1010 = "crypto keyring OnPrem-Aviatrix"
    ios-config-1020 = "pre-shared-key address ${module.gcp_spoke_1.spoke_gateway.eip} key ${var.ace_password}"
    ios-config-1030 = "crypto isakmp policy 1"
    ios-config-1040 = "encryption aes 256"
    ios-config-1050 = "hash sha256"
    ios-config-1060 = "authentication pre-share"
    ios-config-1070 = "group 14"
    ios-config-1080 = "lifetime 28800"
    ios-config-1090 = "crypto isakmp keepalive 10 3 periodic"
    ios-config-1091 = "crypto isakmp profile OnPrem-Aviatrix"
    ios-config-1100 = "keyring OnPrem-Aviatrix"
    ios-config-1110   = "self-identity address"
    ios-config-1120  = "match identity address ${module.gcp_spoke_1.spoke_gateway.eip} 255.255.255.255"
    ios-config-1130 = "crypto ipsec transform-set OnPrem-Aviatrix esp-aes 256 esp-sha256-hmac"
    ios-config-1140 = "mode tunnel"
    ios-config-1150 = "crypto ipsec df-bit clear"
    ios-config-1160 = "crypto ipsec profile OnPrem-Aviatrix"
    ios-config-1170 = "set transform-set OnPrem-Aviatrix"
    ios-config-1180 = "set pfs group14"
    ios-config-1190 = "set isakmp-profile OnPrem-Aviatrix"
    ios-config-1200 = "interface Tunnel1
    ios-config-1210 = "ip address 169.255.0.1 255.255.255.255"
    ios-config-1220 = "ip mtu 1436"
    ios-config-1230 = "ip tcp adjust-mss 1387"
    ios-config-1240 = "tunnel source GigabitEthernet1"
    ios-config-1250 = "tunnel mode ipsec ipv4"
    ios-config-1260 = "tunnel destination ${module.gcp_spoke_1.spoke_gateway.eip}"
    ios-config-1270 = "tunnel protection ipsec profile OnPrem-Aviatrix"
    ios-config-1280 = "ip virtual-reassembly"
    ios-config-1300 = "ip route 192.168.1.0 255.255.255.0 Tunnel1"
    ios-config-1310 = "write memory"
  EOF
  tags = {
    Name = "ace-onprem-cisco-csr"
  }
}

data "aws_instance" "ace-onprem-cisco-csr" {
  provider = aws.west2
  filter {
    name   = "tag:Name"
    values = [ "ace-onprem-cisco-csr" ]
  }
  depends_on = [ aws_instance.ace-onprem-cisco-csr ]
}

data "aws_route_table" "ace-onprem-cisco-rtb" {
  provider   = aws.west2
  subnet_id  = module.ace-onprem-partner1.public_subnets[0]
  depends_on = [ module.ace-onprem-partner1 ]
}

resource "aws_route" "ace-onprem-mapped-route" {
  provider               = aws.west2
  route_table_id         = data.aws_route_table.ace-onprem-cisco-rtb.id
  destination_cidr_block = "192.168.1.0/24"
  network_interface_id   = data.aws_instance.ace-onprem-cisco-csr.network_interface_id
  depends_on             = [ module.ace-onprem-partner1, aws_instance.ace-onprem-cisco-csr ]
}

module "ace-onprem-ubu" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  instance_type               = var.aws_test_instance_size
  name                        = "ace-onprem-ubu"
  ami                         = data.aws_ami.ubuntu2.id
  key_name                    = var.onprem_ec2_key_name
  instance_count              = 1
  subnet_id                   = module.ace-onprem-partner1.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ace-onprem-partner1-sg.id]
  associate_public_ip_address = true
  user_data_base64            = base64encode(local.onprem_user_data)
  providers                   = {
    aws = aws.west2
  }
}

output "aws_onprem_csr_public_ip" {
  value = aws_instance.ace-onprem-cisco-csr.public_ip
}

output "aws_onprem_csr_private_ip" {
  value = aws_instance.ace-onprem-cisco-csr.private_ip
}

output "aws_onprem_ubu_public_ip" {
  value = module.ace-onprem-ubu.public_ip
}

output "aws_onprem_ubu_private_ip" {
  value = module.ace-onprem-ubu.private_ip
}