### FireNet ###
module "aws_firenet_1" {
  source                               = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version                              = "1.0.0"
  transit_module                       = module.aws_transit_1
  firewall_image                       = var.aws_firewall_image
  firewall_image_version               = var.aws_firewall_image_version
  keep_alive_via_lan_interface_enabled = true
}

# Transit FireNet Spoke Inspection Policy
resource "aviatrix_transit_firenet_policy" "transit_firenet_policy_1" {
  transit_firenet_gateway_name = var.aws_transit1_name
  inspected_resource_name      = "SPOKE:${var.aws_spoke1_name}"
  depends_on                   = [module.aws_transit_1]
}

resource "aviatrix_transit_firenet_policy" "transit_firenet_policy_2" {
  transit_firenet_gateway_name = var.aws_transit1_name
  inspected_resource_name      = "SPOKE:${var.aws_spoke2_name}"
  depends_on                   = [module.aws_transit_1]
}
