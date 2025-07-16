terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.0.0"
    }
  }
  required_version = ">= 1.1.0"
  }

provider "azurerm" {
    features {}
        tenant_id = "d2e00dbf-08bc-4435-9eae-b20906d73fba"
        subscription_id = "0576692c-db33-4147-a612-04008c34a1d7"
}