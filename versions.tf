terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.54.0"
    }
  }
}

provider "azurerm" {
  features {} # Configuration options
  subscription_id = "09d55635-2a09-4af6-9e93-6bb44383a7aa"
}
