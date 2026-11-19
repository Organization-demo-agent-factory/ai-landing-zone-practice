# Pipeline rehearsal values (sandbox, generic). Same shape as nonprod.tfvars.example.
# None of these are secrets.

subscription_id = "75eac871-7f67-4bc8-8691-d0a947bc0358"
tenant_id       = "873cfe26-04bd-4643-aba6-82b72b38bf4f"
location        = "westus3"

# The module creates this resource group, so it must not already exist.
resource_group_name = "rg-ai-foundation-v2"

name_prefix = "aifv2"

tags = {
  Environment = "practice"
}

existing_vnet_resource_id   = "/subscriptions/75eac871-7f67-4bc8-8691-d0a947bc0358/resourceGroups/rg-practice-net/providers/Microsoft.Network/virtualNetworks/vnet-practice-v2"
dns_zones_resource_group_id = "/subscriptions/75eac871-7f67-4bc8-8691-d0a947bc0358/resourceGroups/rg-practice-dns"

subnet_address_prefixes = {
  private_endpoint = "10.61.1.0/25"
  ai_foundry       = "10.61.0.0/24"
  app_gateway      = "10.61.1.128/26"
  apim             = "10.61.1.192/27"
}

# The sandbox has no private endpoint DNS policy, so the module registers the records itself.
pe_dns_registration_by_policy = false

project_name         = "platform"
project_display_name = "Platform"
project_description  = "Pipeline rehearsal project"

apim_publisher_email = "ai-gateway-practice@example.com"
apim_publisher_name  = "Practice Gateway Owner"
apim_deploy          = false # stage 1; set to true for stage 3 after the route table is attached

enable_telemetry = false
