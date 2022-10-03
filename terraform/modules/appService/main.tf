resource "azurerm_service_plan" "asp" {
  name                = "asp-artseachgov"
  resource_group_name = var.resourcegroup.name
  location            = var.resourcegroup.location
  os_type             = var.AppService.os_type
  sku_name            = var.AppService.asp_sku
  tags                = var.tags
}

resource "azurerm_windows_web_app" "app" {
  name                      = "app-artsearchgov"
  resource_group_name       = var.resourcegroup.name
  location                  = var.resourcegroup.location
  tags                      = var.tags

  service_plan_id           = azurerm_service_plan.asp.id
  virtual_network_subnet_id = var.subnet.id
  https_only                = true

  site_config {
    vnet_route_all_enabled  = true
  }
}