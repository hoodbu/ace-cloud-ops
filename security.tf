# Create a Gateway in Azure Spoke 1 for Egress FQDN
resource "aviatrix_gateway" "ace-azure-egress-fqdn1" {
  cloud_type   = 8
  account_name = var.azure_account_name
  gw_name      = "${var.azure_spoke1_name}-egress"
  vpc_id       = module.azure_spoke_1.vpc.vpc_id
  vpc_reg      = var.azure_spoke1_region
  gw_size      = var.azure_spoke_instance_size
  subnet       = module.azure_spoke_1.vpc.public_subnets[0].cidr
  lifecycle {
    ignore_changes = [
      single_ip_snat
    ]
  }
  single_ip_snat = false
}

resource "aviatrix_fqdn" "fqdn_filter_spoke1" {
  fqdn_mode    = "black"
  fqdn_enabled = true
  gw_filter_tag_list {
    gw_name = aviatrix_gateway.ace-azure-egress-fqdn1.gw_name
  }

  fqdn_tag            = var.egress_fqdn_discover_tag
  manage_domain_names = false
}

# Create a Gateway in Azure Spoke 2 for Egress FQDN
resource "aviatrix_gateway" "ace-azure-egress-fqdn2" {
  cloud_type   = 8
  account_name = var.azure_account_name
  gw_name      = "${var.azure_spoke2_name}-egress"
  vpc_id       = module.azure_spoke_2.vpc.vpc_id
  vpc_reg      = var.azure_spoke2_region
  gw_size      = var.azure_spoke_instance_size
  subnet       = module.azure_spoke_2.vpc.public_subnets[0].cidr
  lifecycle {
    ignore_changes = [
      single_ip_snat
    ]
  }
  single_ip_snat = false
}

resource "aviatrix_fqdn" "fqdn_filter_spoke2" {
  fqdn_mode    = "white"
  fqdn_enabled = true
  gw_filter_tag_list {
    gw_name = aviatrix_gateway.ace-azure-egress-fqdn2.gw_name
  }

  fqdn_tag            = var.egress_fqdn_patches_tag
  manage_domain_names = false
}

resource "aviatrix_fqdn_tag_rule" "fqdn_tag_rule_1" {
  fqdn_tag_name = var.egress_fqdn_patches_tag
  fqdn          = "ntp.ubuntu.com"
  protocol      = "udp"
  port          = "123"
  depends_on = [
    aviatrix_fqdn.fqdn_filter_spoke2
  ]
}

resource "aviatrix_fqdn_tag_rule" "fqdn_tag_rule_2" {
  fqdn_tag_name = var.egress_fqdn_patches_tag
  fqdn          = "*.ubuntu.com"
  protocol      = "tcp"
  port          = "80"
  depends_on = [
    aviatrix_fqdn.fqdn_filter_spoke2
  ]
}