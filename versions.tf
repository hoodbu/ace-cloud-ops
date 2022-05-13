terraform {
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = "~> 2.21.2"

    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.0"

    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0"
}
