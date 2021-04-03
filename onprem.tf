// AWS Marketplace Opt-in Required - https://aws.amazon.com/marketplace/pp?sku=9fmjj3b9hombuy4jawab1i13i

locals {
  onprem_user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname "Call-Center"
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

module "ace-onprem-partner-vpc" {
  providers      = { aws = aws.west2 }
  source         = "terraform-aws-modules/vpc/aws"
  name           = "ace-onprem-partner-vpc"
  cidr           = "172.16.211.0/24"
  azs            = ["eu-west-2a"]
  public_subnets = ["172.16.211.0/24"]

  tags = {
    Terraform   = "true"
    Environment = "ACE"
  }
}

resource "aws_security_group" "ace-onprem-partner-sg" {
  provider = aws.west2
  name     = "ace-onprem-partner-sg"
  vpc_id   = module.ace-onprem-partner-vpc.vpc_id
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
    Name = "ace-onprem-partner-sg"
  }
}

resource "aws_instance" "ace-onprem-partner-csr" {
  provider = aws.west2
  # Find an AMI by deploying manually from the Console first
  # ami                         = "ami-05fecfb63c095734c"
  ami                         = "ami-011222f8fd462cc0c"
  instance_type               = "t2.medium"
  subnet_id                   = module.ace-onprem-partner-vpc.public_subnets[0]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = aws_key_pair.aws_west2_key.key_name
  vpc_security_group_ids      = [aws_security_group.ace-onprem-partner-sg.id]
  user_data                   = <<EOF
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
    Name = "ace-onprem-partner-csr"
  }
}

data "aws_instance" "ace-onprem-partner-csr" {
  provider = aws.west2
  filter {
    name   = "tag:Name"
    values = ["ace-onprem-partner-csr"]
  }
  depends_on = [aws_instance.ace-onprem-partner-csr]
}

data "aws_route_table" "ace-onprem-cisco-rtb" {
  provider   = aws.west2
  subnet_id  = module.ace-onprem-partner-vpc.public_subnets[0]
  depends_on = [module.ace-onprem-partner-vpc]
}

resource "aws_route" "ace-onprem-mapped-route" {
  provider               = aws.west2
  route_table_id         = data.aws_route_table.ace-onprem-cisco-rtb.id
  destination_cidr_block = "192.168.1.0/24"
  network_interface_id   = data.aws_instance.ace-onprem-partner-csr.network_interface_id
  depends_on             = [module.ace-onprem-partner-vpc, aws_instance.ace-onprem-partner-csr]
}

module "ace-onprem-ubu" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  instance_type               = var.aws_test_instance_size
  name                        = "ace-onprem-ubu"
  ami                         = data.aws_ami.ubuntu2.id
  key_name                    = var.onprem_ec2_key_name
  instance_count              = 1
  subnet_id                   = module.ace-onprem-partner-vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ace-onprem-partner-sg.id]
  associate_public_ip_address = true
  user_data_base64            = base64encode(local.onprem_user_data)
  providers = {
    aws = aws.west2
  }
}

output "onprem_partner_csr_public_ip" {
  value = aws_instance.ace-onprem-partner-csr.public_ip
}

output "onprem_partner_csr_private_ip" {
  value = aws_instance.ace-onprem-partner-csr.private_ip
}

output "onprem_ubu_public_ip" {
  value = module.ace-onprem-ubu.public_ip
}

output "onprem_ubu_private_ip" {
  value = module.ace-onprem-ubu.private_ip
}


#############################################################################

module "ace-onprem-dc-vpc" {
  providers      = { aws = aws.west2 }
  source         = "terraform-aws-modules/vpc/aws"
  name           = "ace-onprem-dc-vpc"
  cidr           = "10.0.0.0/24"
  azs            = ["eu-west-2a"]
  public_subnets = ["10.0.0.0/24"]

  tags = {
    Terraform   = "true"
    Environment = "ACE"
  }
}

resource "aws_security_group" "ace-onprem-dc-sg" {
  provider = aws.west2
  name     = "ace-onprem-dc-sg"
  vpc_id   = module.ace-onprem-dc-vpc.vpc_id
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
    Name = "ace-onprem-dc-sg"
  }
}

resource "aws_instance" "ace-onprem-dc-csr" {
  provider = aws.west2
  # Find an AMI by deploying manually from the Console first
  # ami                         = "ami-05fecfb63c095734c"
  ami                         = "ami-011222f8fd462cc0c"
  instance_type               = "t2.medium"
  subnet_id                   = module.ace-onprem-dc-vpc.public_subnets[0]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = aws_key_pair.aws_west2_key.key_name
  vpc_security_group_ids      = [aws_security_group.ace-onprem-dc-sg.id]
  user_data                   = <<EOF
    ios-config-100 = "username admin privilege 15 password ${var.ace_password}"
    ios-config-1600 = "write memory"
  EOF
  tags = {
    Name = "ace-onprem-dc-csr"
  }
}

/* 
resource "aws_instance" "ace-onprem-dc-csr" {
  provider = aws.west2
  # Find an AMI by deploying manually from the Console first
  # ami                         = "ami-05fecfb63c095734c"
  ami                         = "ami-011222f8fd462cc0c"
  instance_type               = "t2.medium"
  subnet_id                   = module.ace-onprem-dc-vpc.public_subnets[0]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = aws_key_pair.aws_west2_key.key_name
  vpc_security_group_ids      = [aws_security_group.ace-onprem-dc-sg.id]
  user_data                   = <<EOF
    ios-config-100 = "username admin privilege 15 password ${var.ace_password}"
    ios-config-104 = "hostname OnPrem-DC"
    ios-config-1010 = "crypto keyring OnPrem-DC-Aviatrix"
    ios-config-1020 = "pre-shared-key address ${module.aws_transit_1.transit_gateway.eip} key ${var.ace_password}"
    ios-config-1030 = "crypto isakmp policy 1"
    ios-config-1040 = "encryption aes 256"
    ios-config-1050 = "hash sha256"
    ios-config-1060 = "authentication pre-share"
    ios-config-1070 = "group 14"
    ios-config-1080 = "lifetime 28800"
    ios-config-1090 = "crypto isakmp keepalive 10 3 periodic"
    ios-config-1091 = "crypto isakmp profile OnPrem-DC-Aviatrix"
    ios-config-1100 = "keyring OnPrem-DC-Aviatrix"
    ios-config-1110 = "self-identity address"
    ios-config-1120 = "match identity address ${module.aws_transit_1.transit_gateway.eip} 255.255.255.255"
    ios-config-1130 = "crypto ipsec transform-set OnPrem-DC-Aviatrix esp-aes 256 esp-sha256-hmac"
    ios-config-1140 = "mode tunnel"
    ios-config-1150 = "crypto ipsec df-bit clear"
    ios-config-1160 = "crypto ipsec profile OnPrem-DC-Aviatrix"
    ios-config-1165 = "set security-association lifetime seconds 3600"
    ios-config-1170 = "set transform-set OnPrem-DC-Aviatrix"
    ios-config-1180 = "set pfs group14"
    ios-config-1190 = "set isakmp-profile OnPrem-DC-Aviatrix"
    ios-config-1200 = "interface Tunnel1"
    ios-config-1210 = "ip address 169.254.74.129 255.255.255.252"
    ios-config-1220 = "ip mtu 1436"
    ios-config-1230 = "ip tcp adjust-mss 1387"
    ios-config-1240 = "tunnel source GigabitEthernet1"
    ios-config-1250 = "tunnel mode ipsec ipv4"
    ios-config-1260 = "tunnel destination ${module.aws_transit_1.transit_gateway.eip}"
    ios-config-1270 = "tunnel protection ipsec profile OnPrem-DC-Aviatrix"
    ios-config-1280 = "ip virtual-reassembly"
    ios-config-1300 = "router bgp 65001"
    ios-config-1310 = "bgp log-neighbor-changes"
    ios-config-1320 = "neighbor 169.254.74.130 remote-as 65000"
    ios-config-1330 = "neighbor 169.254.74.130 timers 10 30 30"
    ios-config-1340 = "address-family ipv4"
    ios-config-1350 = "redistribute connected"
    ios-config-1360 = "neighbor 169.254.74.130 activate"
    ios-config-1370 = "neighbor 169.254.74.130 soft-reconfiguration inbound"
    ios-config-1380 = "maximum-paths 2"
    ios-config-1390 = "interface Loopback0"
    ios-config-1400 = "ip address 10.0.0.1 255.255.255.128"
    ios-config-1410 = "interface Loopback1"
    ios-config-1420 = "ip address 10.0.1.1 255.255.255.128"
    ios-config-1430 = "interface Loopback2"
    ios-config-1440 = "ip address 10.0.2.1 255.255.255.128"
    ios-config-1600 = "write memory"
  EOF
  tags = {
    Name = "ace-onprem-dc-csr"
  }
}

output "onprem_dc_csr_public_ip" {
  value = aws_instance.ace-onprem-dc-csr.public_ip
}

output "onprem_dc_csr_private_ip" {
  value = aws_instance.ace-onprem-dc-csr.private_ip
}
*/