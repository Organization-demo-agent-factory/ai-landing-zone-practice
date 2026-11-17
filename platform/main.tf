module "ai_landing_zone" {
  source  = "Azure/avm-ptn-aiml-landing-zone/azurerm"
  version = "0.5.3"

  location            = var.location
  resource_group_name = var.resource_group_name
  name_prefix         = var.name_prefix
  tags                = var.tags
  enable_telemetry    = var.enable_telemetry

  # Bring your own VNet: the module reads this VNet and creates its subnets and NSG inside it.
  vnet_definition = {
    existing_byo_vnet = {
      this_vnet = {
        vnet_resource_id = var.existing_vnet_resource_id
      }
    }
  }

  # The platform team owns hub, routing and DNS. This also keeps the demo VMs, bastion and firewall out.
  flag_platform_landing_zone = true

  private_dns_zones = {
    existing_zones_resource_group_resource_id = var.dns_zones_resource_group_id
    azure_policy_pe_zone_linking_enabled      = var.pe_dns_registration_by_policy
  }

  # AI gateway: Developer x1 for non-prod (module default is Premium x3, about $8.4K a month).
  apim_definition = {
    publisher_email = var.apim_publisher_email
    publisher_name  = var.apim_publisher_name
    sku_root        = var.apim_sku_root
    sku_capacity    = var.apim_sku_capacity
  }

  # Foundry account and project. No model deployments: the foundation only.
  ai_foundry_definition = {
    ai_foundry = {
      disable_local_auth      = true
      create_ai_agent_service = false # open item: confirm Agent Service in the foundation
    }

    ai_projects = {
      platform = {
        name                       = var.project_name
        display_name               = var.project_display_name
        description                = var.project_description
        create_project_connections = true
        cosmos_db_connection       = { new_resource_map_key = "this" }
        ai_search_connection       = { new_resource_map_key = "this" }
        key_vault_connection       = { new_resource_map_key = "this" }
        storage_account_connection = { new_resource_map_key = "this" }
      }
    }

    ai_search_definition = {
      this = {
        local_authentication_enabled = false
        replica_count                = 1
      }
    }

    cosmosdb_definition = {
      this = {
        consistency_level = "Session"
        # An empty list makes the module add the paired region (East US for West US 3) as a second location.
        # One entry with only the primary region keeps the account single-region.
        secondary_regions = [
          { location = var.location, zone_redundant = false, failover_priority = 0 }
        ]
      }
    }

    key_vault_definition = {
      this = {}
    }

    storage_account_definition = {
      this = {
        shared_access_key_enabled = false
        endpoints = {
          blob = { type = "blob" }
        }
      }
    }
  }

  # Extras that default to on. Turn each off explicitly; deleting the block would leave it on.
  ks_ai_search_definition              = { deploy = false }
  ks_bing_grounding_definition         = { deploy = false }
  container_app_environment_definition = { deploy = false }
  genai_app_configuration_definition   = { deploy = false }
  genai_container_registry_definition  = { deploy = false }
  genai_cosmosdb_definition            = { deploy = false }
  genai_key_vault_definition           = { deploy = false }
  genai_storage_account_definition     = { deploy = false }
  buildvm_definition                   = { deploy = false }
  jumpvm_definition                    = { deploy = false }
  bastion_definition                   = { deploy = false }
  firewall_definition                  = { deploy = false }

  # The module reads this input even when the gateway is off, so it must be set.
  # deploy = false means no Application Gateway is created; the entries below only satisfy the input schema.
  app_gateway_definition = {
    deploy = false
    backend_address_pools = {
      placeholder = { name = "placeholder-pool" }
    }
    backend_http_settings = {
      placeholder = { name = "placeholder-settings", port = 80, protocol = "Http" }
    }
    frontend_ports = {
      placeholder = { name = "placeholder-port", port = 80 }
    }
    http_listeners = {
      placeholder = { name = "placeholder-listener", frontend_port_name = "placeholder-port" }
    }
    request_routing_rules = {
      placeholder = {
        name                       = "placeholder-rule"
        rule_type                  = "Basic"
        http_listener_name         = "placeholder-listener"
        backend_address_pool_name  = "placeholder-pool"
        backend_http_settings_name = "placeholder-settings"
        priority                   = 100
      }
    }
  }
}

output "ai_landing_zone_resource_id" {
  value = module.ai_landing_zone.resource_id
}
