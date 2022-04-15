### FireNet ###
module "aws_firenet_1" {
  source                               = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version                              = "1.0.0"
  transit_module                       = module.aws_transit_1
  firewall_image                       = var.aws_firewall_image
  firewall_image_version               = var.aws_firewall_image_version
  keep_alive_via_lan_interface_enabled = true
  custom_fw_names = ["ACE-FW"]
  user_data_1     = local.fw1
}

locals {
  fw1 = templatefile("fortigate_bootstrap.tpl", {
    name     = "ACE-FW"
    password = var.ace_password
    }
  )
}

data "aviatrix_firenet_vendor_integration" "ven_int" {
  vpc_id        = module.mc_transit_aws.vpc.vpc_id
  instance_id   = module.mc_firenet_aws.aviatrix_firewall_instance[0].instance_id
  vendor_type   = "Fortinet FortiGate"
  public_ip     = module.mc_firenet_aws.aviatrix_firewall_instance[0].public_ip
  username      = "ACE"
  firewall_name = module.mc_firenet_aws.aviatrix_firewall_instance[0].firewall_name
  save          = true
  api_token     = "gnk1dQkGpg77jQ6d6r543Qqc05Q5p3"
  depends_on = [
    module.mc_firenet_aws
  ]
}

# Transit FireNet Spoke Inspection Policy
resource "aviatrix_transit_firenet_policy" "transit_firenet_policy_1" {
  transit_firenet_gateway_name = var.aws_transit1_name
  inspected_resource_name      = "SPOKE:${var.aws_spoke1_name}"
  depends_on                   = [module.aws_firenet_1]
}

resource "aviatrix_transit_firenet_policy" "transit_firenet_policy_2" {
  transit_firenet_gateway_name = var.aws_transit1_name
  inspected_resource_name      = "SPOKE:${var.aws_spoke2_name}"
  depends_on                   = [module.aws_firenet_1]
}
