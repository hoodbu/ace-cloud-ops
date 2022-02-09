terraform {
  required_providers {
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
      # version = "~> 2.20.1"
      version = "2.21.0-6.6.ga"

    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0.0"

    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0"
}