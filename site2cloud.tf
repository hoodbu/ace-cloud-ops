### OnPrem Partner Site2Cloud ### 
resource "aviatrix_site2cloud" "s2c-onprem-partner" {
  vpc_id                     = module.gcp_spoke_1.vpc.vpc_id
  connection_name            = "ACE-ONPREM-CALLCENTER"
  connection_type            = "mapped"
  remote_gateway_type        = "generic"
  tunnel_type                = "route"
  enable_ikev2               = true
  primary_cloud_gateway_name = module.gcp_spoke_1.vpc.name
  remote_gateway_ip          = aws_eip_association.eip_assoc.public_ip
  pre_shared_key             = var.ace_password
  local_tunnel_ip            = "169.254.0.1/30"
  remote_tunnel_ip           = "169.254.0.2/30"
  local_subnet_cidr          = "172.16.211.0/24"
  local_subnet_virtual       = "192.168.1.0/24"
  remote_subnet_cidr         = "172.16.211.0/24"
  remote_subnet_virtual      = "192.168.2.0/24"
}

### OnPrem DC Site2Cloud ### 
resource "aviatrix_transit_external_device_conn" "s2c-onprem-dc" {
  vpc_id                   = module.aws_transit_1.vpc.vpc_id
  connection_name          = "ACE-ONPREM-DC"
  gw_name                  = module.aws_transit_1.vpc.name
  remote_gateway_ip        = aws_instance.ace-onprem-dc-csr.public_ip
  pre_shared_key           = var.ace_password
  phase1_remote_identifier = [aws_instance.ace-onprem-dc-csr.private_ip]
  connection_type          = "bgp"
  direct_connect           = false
  bgp_local_as_num         = "65011"
  bgp_remote_as_num        = "65012"
  ha_enabled               = false
  local_tunnel_cidr        = "169.254.74.130/30"
  remote_tunnel_cidr       = "169.254.74.129/30"
  custom_algorithms        = false
}

resource "aviatrix_segmentation_network_domain_association" "test_segmentation_network_domain_association" {
  transit_gateway_name = var.aws_transit1_name
  network_domain_name  = "BU1"
  attachment_name      = aviatrix_transit_external_device_conn.s2c-onprem-dc.connection_name
  depends_on = [
    module.aws_transit_1,
    aviatrix_segmentation_network_domain.BU1
  ]
}
