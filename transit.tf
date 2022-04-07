// ACE-ops Core Aviatrix Infrastructure

# Private Key creation
resource "tls_private_key" "avtx_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "aws_west1_key" {
  provider   = aws.west
  key_name   = var.ec2_key_name
  public_key = tls_private_key.avtx_key.public_key_openssh
}

resource "aws_key_pair" "aws_west2_key" {
  provider   = aws.west2
  key_name   = var.ec2_key_name
  public_key = tls_private_key.avtx_key.public_key_openssh
}

# AWS Transit Modules
module "aws_transit_1" {
  source                               = "terraform-aviatrix-modules/aws-transit-firenet/aviatrix"
  version                              = "5.0.0"
  account                              = var.aws_account_name
  region                               = var.aws_transit1_region
  name                                 = var.aws_transit1_name
  cidr                                 = var.aws_transit1_cidr
  ha_gw                                = var.ha_enabled
  prefix                               = var.prefix
  suffix                               = var.suffix
  egress_enabled                       = false
  insane_mode                          = false
  instance_size                        = var.aws_transit_instance_size
  enable_segmentation                  = true
  keep_alive_via_lan_interface_enabled = true
  firewall_image                       = var.aws_firewall_image
  firewall_image_version               = var.aws_firewall_image_version
}

# AWS Spoke Modules
module "aws_spoke_1" {
  source          = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version         = "1.1.0"
  cloud           = "AWS"
  account         = var.aws_account_name
  region          = var.aws_spoke1_region
  name            = var.aws_spoke1_name
  cidr            = var.aws_spoke1_cidr
  ha_gw           = var.ha_enabled
  instance_size   = var.aws_spoke_instance_size
  security_domain = aviatrix_segmentation_security_domain.BU1.domain_name
  transit_gw      = module.aws_transit_1.transit_gateway.gw_name
}

module "aws_spoke_2" {
  source          = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version         = "1.1.0"
  cloud           = "AWS"
  account         = var.aws_account_name
  region          = var.aws_spoke2_region
  name            = var.aws_spoke2_name
  cidr            = var.aws_spoke2_cidr
  ha_gw           = var.ha_enabled
  instance_size   = var.aws_spoke_instance_size
  security_domain = aviatrix_segmentation_security_domain.BU2.domain_name
  transit_gw      = module.aws_transit_1.transit_gateway.gw_name
}

# Azure Transit Module
module "azure_transit_1" {
  source              = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version             = "1.1.0"
  cloud               = "Azure"
  ha_gw               = var.ha_enabled
  account             = aviatrix_account.azure_account.account_name
  region              = var.azure_transit1_region
  name                = var.azure_transit1_name
  cidr                = var.azure_transit1_cidr
  instance_size       = var.azure_transit_instance_size
  enable_segmentation = true
}

# Azure Spoke 1 
module "azure_spoke_1" {
  source          = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version         = "1.1.0"
  cloud           = "Azure"
  account         = aviatrix_account.azure_account.account_name
  region          = var.azure_spoke1_region
  name            = var.azure_spoke1_name
  cidr            = var.azure_spoke1_cidr
  instance_size   = var.azure_spoke_instance_size
  ha_gw           = var.ha_enabled
  security_domain = aviatrix_segmentation_security_domain.BU1.domain_name
  transit_gw      = module.azure_transit_1.transit_gateway.gw_name
}

# Azure Spoke 2
module "azure_spoke_2" {
  source          = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version         = "1.1.0"
  cloud           = "Azure"
  account         = aviatrix_account.azure_account.account_name
  region          = var.azure_spoke2_region
  name            = var.azure_spoke2_name
  cidr            = var.azure_spoke2_cidr
  instance_size   = var.azure_spoke_instance_size
  ha_gw           = var.ha_enabled
  security_domain = aviatrix_segmentation_security_domain.BU2.domain_name
  transit_gw      = module.azure_transit_1.transit_gateway.gw_name
}

# GCP Transit Module
module "gcp_transit_1" {
  source              = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version             = "1.1.0"
  cloud               = "GCP"
  account             = var.gcp_account_name
  region              = var.gcp_transit1_region
  name                = var.gcp_transit1_name
  cidr                = var.gcp_transit1_cidr
  enable_segmentation = true
  ha_gw               = var.ha_enabled
}

# Aviatrix GCP Spoke 1
module "gcp_spoke_1" {
  source          = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version         = "1.1.0"
  cloud           = "GCP"
  account         = var.gcp_account_name
  region          = var.gcp_spoke1_region
  name            = var.gcp_spoke1_name
  cidr            = var.gcp_spoke1_cidr
  ha_gw           = var.ha_enabled
  security_domain = aviatrix_segmentation_security_domain.BU1.domain_name
  transit_gw      = module.gcp_transit_1.transit_gateway.gw_name
}

# Multi region Multi-Cloud transit peering
module "transit-peering" {
  # source = "git::https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit-peering.git?ref=v1.0.3"
  source  = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"
  version = "1.0.3"
  transit_gateways = [
    module.gcp_transit_1.transit_gateway.gw_name,
    module.azure_transit_1.transit_gateway.gw_name,
    module.aws_transit_1.transit_gateway.gw_name
  ]
  excluded_cidrs = [
    "0.0.0.0/0",
  ]
}

# Multi-Cloud Segmentation
resource "aviatrix_segmentation_security_domain" "BU2" {
  domain_name = "BU2"
  depends_on = [
    module.aws_transit_1,
    module.azure_transit_1,
    module.gcp_transit_1
  ]
}
resource "aviatrix_segmentation_security_domain" "BU1" {
  domain_name = "BU1"
  depends_on = [
    module.aws_transit_1,
    module.azure_transit_1,
    module.gcp_transit_1
  ]
}
/* resource "aviatrix_segmentation_security_domain_connection_policy" "BU1_BU2" {
  domain_name_1 = "BU1"
  domain_name_2 = "BU2"
  depends_on = [aviatrix_segmentation_security_domain.BU1, aviatrix_segmentation_security_domain.BU2]
} */