

resource "random_string" "random" {
  length = 8
  special = false
  lower = true
  upper = false
}

resource "azurerm_resource_group" "core" {
	name        = "rg-ARTSearch-${var.location}-${random_string.random.result}"
	location    = var.location
  tags        = var.tags 
}

module "network" {
  source = "./modules/network"
  resourcegroup   = azurerm_resource_group.core
  tags            = var.tags
  random          = random_string.random.result

  virtualnetwork  = var.virtualNetwork
  subnets         = var.subnets
}

module "appService" {
  source = "./modules/appService"
  resourcegroup = azurerm_resource_group.core
  tags          = var.tags

  AppService    = var.AppService
  subnet        = module.network.subnets["appService"]  
}

module "cogsvcs" {
  source          = "./modules/cogsvcs"
  resourcegroup   = azurerm_resource_group.core
  tags            = var.tags
  random          = random_string.random.result
  
  cogsvcs         = var.cogsvcs
  virtualnetwork  = module.network.vnet
  subnet          = module.network.subnets["prvtsvcs"]
  azSearch        = var.azSearch
  asp_public_ip   = module.appService.asp_public_ip
}