locals {
  dns_search_pl       = "privatelink.search.windows.net"
  dns_search          = "search.windows.net"
  dns_search_pl_gov   = "search.azure.us"
  dns_cogServices     = "cognitiveservices.azure.com"
  dns_cogServices_gov = "cognitiveservices.azure.us"
}

resource "azurerm_cognitive_account" "cogsvcs" {
  for_each            = var.cogsvcs.services
  name                = "cog-${each.value}-${var.random}"
  location            = var.resourcegroup.location
  resource_group_name = var.resourcegroup.name
  tags                = var.tags

  kind                = each.value
  custom_subdomain_name = lower("art-${each.value}-${var.random}")
  network_acls {
    default_action = "Deny"
    ip_rules = concat(var.cogsvcs.allowed_ips, var.asp_public_ip)

    # Only add VNET rule when AzSeach public access is disabled
    dynamic "virtual_network_rules" {
      for_each = toset(var.azSearch.public_access == false ? ["fake"] : [])
      content {
        subnet_id = var.subnet.id
      }
    }
  }
  sku_name = "S0"
}

resource "azurerm_private_dns_zone" "cog-services" {
  name                = var.environment == "gov" ? local.dns_cogServices_gov : local.dns_cogServices
  resource_group_name = var.resourcegroup.name
  tags                = var.tags 
}

resource "azurerm_private_dns_zone_virtual_network_link" "cog-services" {
  name                  = "link-cog-services-${var.random}"
  resource_group_name   = var.resourcegroup.name
  private_dns_zone_name = azurerm_private_dns_zone.cog-services.name
  virtual_network_id    = var.virtualnetwork.id
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "cog-endpoints" {
  /*
  loop through the three synapse workspace interfaces [dev | sql | sqlondemand]
  and create a priavte link to the vnet for each.

  https://learn.microsoft.com/en-us/azure/cognitive-services/cognitive-services-virtual-networks?tabs=portal#use-private-endpoints
  */
	for_each            = var.cogsvcs.services
  name                = lower("pl-cog-${each.value}-${var.random}")
  resource_group_name = var.resourcegroup.name
  location            = var.resourcegroup.location
  subnet_id           = var.subnet.id
  tags                = var.tags

  private_service_connection {
    name                            = "pe-cog-${each.value}-${var.random}"
    is_manual_connection            = false
    private_connection_resource_id  = azurerm_cognitive_account.cogsvcs[each.value].id
    subresource_names               = ["account"]
  }

  private_dns_zone_group {
    name                  = each.value
    private_dns_zone_ids  = [
      azurerm_private_dns_zone.cog-services.id
    ]
  }
}

resource "azurerm_search_service" "search" {
  name                          = "search-${var.random}"
  resource_group_name           = var.resourcegroup.name
  location                      = var.resourcegroup.location
  tags = var.tags

  sku                           = var.azSearch.sku
  public_network_access_enabled = var.azSearch.public_access
  replica_count                 = var.azSearch.replica_count
  partition_count               = var.azSearch.partition_count
  allowed_ips                   = concat(var.azSearch.allowed_ips, var.asp_public_ip)
  identity {
    type = "SystemAssigned"
  }
}

/*
Azure Search Private Endpoints

The variable azSearch.public_access manages if private endpoints for the Azure search service will be deployed.
  TRUE == public access enabled on Azure Search and no private endpoint resources are deployed.
  FALSE == public access disabled on Azure Search and private endpoints and DNS Zones are deployed. 

  https://learn.microsoft.com/en-us/azure/search/service-create-private-endpoint
*/
resource "azurerm_private_dns_zone" "search-pl" {
  count               = var.azSearch.create_priavte_dns_zone == false ? 0 : 1
  name                = var.environment == "gov" ? local.dns_search_gov : local.dns_search_pl
  resource_group_name = var.resourcegroup.name
  tags                = var.tags 
}

resource "azurerm_private_endpoint" "search-endpoints" {
  /*
  loop through the three synapse workspace interfaces [dev | sql | sqlondemand]
  and create a priavte link to the vnet for each.

  https://learn.microsoft.com/en-us/azure/cognitive-services/cognitive-services-virtual-networks?tabs=portal#use-private-endpoints
  */
  name                = lower("pl-search-${var.random}")
  count               = var.azSearch.enable_private_endpoint == false ? 0 : 1
  resource_group_name = var.resourcegroup.name
  location            = var.resourcegroup.location
  subnet_id           = var.subnet.id
  tags                = var.tags

  private_service_connection {
    name                            = "pe-search-${var.random}"
    is_manual_connection            = false
    private_connection_resource_id  = azurerm_search_service.search.id
    subresource_names               = ["searchService"]
  }


  dynamic "private_dns_zone_group" {
    for_each = toset(var.azSearch.create_priavte_dns_zone != false ? ["fake"] : [])
    content {
      name                  = "search"
      private_dns_zone_ids  = [
        azurerm_private_dns_zone.search-pl[count.index].id
      ]      
    }
  }
}

