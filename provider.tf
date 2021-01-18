provider "aviatrix" {
  version       = "2.17.1"
  controller_ip = var.controller_ip
  username      = var.username
  password      = var.password
}

provider "azurerm" {
  version = "~> 2.0.0"
  features {}
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

provider "google" {
  project     = "aviatrix-uhoodbhoy"   # REPLACE_ME
  region      = "us-east1"
}

provider "aws" {
  alias  = "west"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "west2"
  region = "eu-west-2"
}
