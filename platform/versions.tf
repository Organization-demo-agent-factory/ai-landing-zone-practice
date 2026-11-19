terraform {
  required_version = ">= 1.12, < 2.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.12"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
  }

  # Backend values are passed with -backend-config in the workflow (one state key per environment).
  backend "azurerm" {
    use_oidc         = true
    use_azuread_auth = true
  }
}

provider "azurerm" {
  subscription_id     = var.subscription_id
  tenant_id           = var.tenant_id
  use_oidc            = true
  storage_use_azuread = true
  features {}
}

provider "azapi" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  use_oidc        = true
}

# AVM telemetry off (customer decision). In module 0.5.3 enable_telemetry does not reach two
# nested modules (regions and NSG), so the telemetry provider is switched off here as well.
provider "modtm" {
  enabled = false
}
