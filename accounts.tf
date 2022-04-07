# Create an Aviatrix Azure Account
resource "aviatrix_account" "azure_account" {
  account_name        = var.azure_account_name
  cloud_type          = 8
  arm_subscription_id = var.azure_subscription_id
  arm_directory_id    = var.azure_tenant_id
  arm_application_id  = var.azure_client_id
  arm_application_key = var.azure_client_secret
}