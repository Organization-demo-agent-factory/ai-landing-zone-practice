subscription_id = "75eac871-7f67-4bc8-8691-d0a947bc0358"
tenant_id       = "873cfe26-04bd-4643-aba6-82b72b38bf4f"
location        = "westus3"

resource_group_name = "rg-ai-foundation-practice"
name_prefix         = "aifprac"

tags = {
  Environment = "practice"
}

existing_vnet_resource_id   = "/subscriptions/75eac871-7f67-4bc8-8691-d0a947bc0358/resourceGroups/rg-practice-net/providers/Microsoft.Network/virtualNetworks/vnet-practice"
dns_zones_resource_group_id = "/subscriptions/75eac871-7f67-4bc8-8691-d0a947bc0358/resourceGroups/rg-practice-dns"

pe_dns_registration_by_policy = false

project_name         = "platform"
project_display_name = "Platform"
project_description  = "Practice foundation project"

apim_publisher_email = "ai-gateway-practice@example.com"
apim_publisher_name  = "Practice Gateway Owner"
