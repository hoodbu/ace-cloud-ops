output "firewall_public_ip" {
  value = module.aws_firenet_1.aviatrix_firewall_instance[0].public_ip
}

output "onprem_partner_csr_public_ip" {
  value = aws_eip.ace-onprem-partner-csr-eip.public_ip
}

output "onprem_partner_csr_private_ip" {
  value = aws_instance.ace-onprem-partner-csr.private_ip
}

output "onprem_ubu_public_ip" {
  value = module.ace-onprem-ubu.public_ip
}

output "onprem_ubu_private_ip" {
  value = data.aws_network_interface.ace-onprem-ubu-ni.private_ip
}

output "onprem_dc_csr_public_ip" {
  value = aws_instance.ace-onprem-dc-csr.public_ip
}

output "onprem_dc_csr_private_ip" {
  value = aws_instance.ace-onprem-dc-csr.private_ip
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

output "azure_spoke1_ubu_private_ip" {
  value = azurerm_linux_virtual_machine.azure_spoke1_vm.private_ip_address
}

output "azure_spoke2_ubu_private_ip" {
  value = azurerm_linux_virtual_machine.azure_spoke2_vm.private_ip_address
}

output "gcp_spoke1_ubu_public_ip" {
  value = google_compute_address.gcp-spoke1-eip.address
}

output "gcp_spoke1_ubu_private_ip" {
  value = google_compute_instance.gcp-spoke1-ubu.network_interface[0].network_ip
}
