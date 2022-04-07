variable "ace_email" {
  type = string
}

variable "ace_password" {
  type = string
}

variable "prefix" {
  type    = bool
  default = false
}

variable "suffix" {
  type    = bool
  default = false
}

variable "aws_account_name" {
  default = "aws-account"
}

variable "aws_transit_instance_size" {
  default = "c5.xlarge"
}

variable "aws_transit1_region" {
  default = "eu-west-1"
}

variable "aws_transit1_name" {
  default = "ace-aws-eu-west-1-transit1"
}

variable "aws_transit1_cidr" {
  default = "10.1.200.0/23"
}

variable "aws_firewall_image" {
  default = "Fortinet FortiGate Next-Generation Firewall"
}

variable "aws_firewall_image_version" {
  default = "(7.0.5)"
}

variable "aws_spoke_instance_size" {
  default = "t3.micro"
}

variable "aws_spoke1_region" {
  default = "eu-west-1"
}

variable "aws_spoke1_name" {
  default = "ace-aws-eu-west-1-spoke1"
}

variable "aws_spoke1_cidr" {
  default = "10.1.211.0/24"
}

variable "aws_spoke2_region" {
  default = "eu-west-1"
}

variable "aws_spoke2_name" {
  default = "ace-aws-eu-west-1-spoke2"
}

variable "aws_spoke2_cidr" {
  default = "10.1.212.0/24"
}

variable "aws_test_instance_size" {
  default = "c5n.xlarge"
}

variable "ec2_key_name" {
  default = "ace-cloud-ops"
}

variable "azure_account_name" {
  default = "azure-account"
}

variable "azure_subscription_id" {
}

variable "azure_client_id" {
}

variable "azure_client_secret" {
}

variable "azure_tenant_id" {
}

variable "azure_transit1_region" {
  default = "East US"
}

variable "azure_transit1_name" {
  default = "ace-azure-east-us-transit1"
}

variable "azure_transit1_cidr" {
  default = "192.168.200.0/23"
}

variable "azure_spoke1_region" {
  default = "East US"
}

variable "azure_spoke1_name" {
  default = "ace-azure-east-us-spoke1"
}

variable "azure_spoke1_cidr" {
  default = "192.168.211.0/24"
}

variable "azure_spoke2_region" {
  default = "East US"
}

variable "azure_spoke2_name" {
  default = "ace-azure-east-us-spoke2"
}

variable "azure_spoke2_cidr" {
  default = "192.168.212.0/24"
}

variable "insane" {
  type    = bool
  default = true
}

variable "transit_ha_enabled" {
  type    = bool
  default = false
}

variable "spoke_ha_enabled" {
  type    = bool
  default = false
}

variable "azure_transit_instance_size" {
  default = "Standard_B2ms"
}

variable "azure_spoke_instance_size" {
  default = "Standard_B1ms"
}

variable "azure_test_instance_size" {
  default = "Standard_B1ms"
}

variable "gcp_account_name" {
  default = "gcp-account"
}

variable "account_name_in_gcp" {
}

variable "gcp_transit1_region" {
  default = "us-east1"
}

variable "gcp_transit1_name" {
  default = "ace-gcp-us-east1-transit1"
}

variable "gcp_transit1_cidr" {
  default = "172.16.200.0/23"
}

variable "gcp_spoke1_region" {
  default = "us-east1"
}

variable "gcp_spoke1_name" {
  default = "ace-gcp-us-east1-spoke1"
}

variable "gcp_spoke1_cidr" {
  default = "172.16.211.0/24"
}

variable "gcp_test_instance_size" {
  default = "f1-micro"
}

variable "egress_fqdn_patches_tag" {
  default = "ACE-UBUNTU-PATCHES"
}

variable "egress_fqdn_discover_tag" {
  default = "ACE-DISCOVER"
}
