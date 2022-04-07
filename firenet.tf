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
