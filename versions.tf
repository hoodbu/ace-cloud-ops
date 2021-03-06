terraform {
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = "~> 2.19.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0.0"

    }
    aws = {
      source = "hashicorp/aws"
      # version = "~> 2.0"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.15"
}
