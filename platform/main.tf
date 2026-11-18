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
    # The module's default subnet sizes assume a /20, so set each prefix explicitly.
    # The module attaches its NSG to every subnet it creates. Keep ContainerAppEnvironmentSubnet off:
    # the module gives it no NSG, which a Deny-Subnet-Without-Nsg policy would block.
    subnets = {
      PrivateEndpointSubnet         = { address_prefix = var.subnet_address_prefixes.private_endpoint }
      AIFoundrySubnet               = { address_prefix = var.subnet_address_prefixes.ai_foundry }
      AppGatewaySubnet              = { address_prefix = var.subnet_address_prefixes.app_gateway }
      APIMSubnet                    = { enabled = false } # the gateway is deployed next to this module, not by it
      ContainerAppEnvironmentSubnet = { enabled = false }
      DevOpsBuildSubnet             = { enabled = false }
    }
  }

  # The platform team owns hub, routing and DNS. This also keeps the demo VMs, bastion and firewall out.
  flag_platform_landing_zone = true

  private_dns_zones = {
    existing_zones_resource_group_resource_id = var.dns_zones_resource_group_id
    azure_policy_pe_zone_linking_enabled      = var.pe_dns_registration_by_policy
  }

  # AI gateway: the platform team deploys API Management next to this module, with its own code, because in
  # platform mode the module's APIM subnet gets no route table (Internal-mode APIM then fails with
  # 422 ManagementApiRequestFailed on port 3443 when 0.0.0.0/0 is forced through a firewall).
  # The module still reads these two values when its own gateway is off.
  apim_definition = {
    deploy          = false
    publisher_email = var.apim_publisher_email
    publisher_name  = var.apim_publisher_name
  }

  # Foundry account and project. No model deployments: the foundation only.
  ai_foundry_definition = {
    ai_foundry = {
      disable_local_auth      = true
      create_ai_agent_service = true # Agent Service on
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
        # Key auth stays on for this account in 0.5.3 whatever you set here: the Cosmos module (0.10.0) applies
        # local_authentication_disabled only when SQL databases are defined in Terraform. Audit it with Azure Policy.
        # An empty list makes the module add the paired region (East US for West US 3) as a second location.
        # One entry with only the primary region keeps the account single-region.
        secondary_regions = [
          { location = var.location, zone_redundant = false, failover_priority = 0 }
        ]
        # Cost guard: the module default (-1) is uncapped. Agent Service needs 3,000 RU/s to set up and up to
        # 5,000 RU/s per project once agents use the Responses API, so cap at 5,000 per project.
        capacity = {
          total_throughput_limit = 5000
        }
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
