variable "environment" {
  type    = string
  default = "public"
}

variable "tags" {
  description = "Key value list of Azure resource tags"
  type = map
}

variable "location" {
  description = "Default Azure Region"
  type        = string
}

variable "virtualNetwork" {
  description = "Virtual network configuration"
  type = object({
    address_space= list(string) # List of IPv4 address space(s) to configure on the virtual network 
  })
}

variable "subnets" {
  description = "Subnets"
  type = list(object(
    {
      name                      = optional(string, "prvtsvcs") # Subnet Name
      address_prefix            = list(string)                 # Subnet IPv4 prefix
      delegation                = optional(string, null)       # Azure service delegation (optional)
      enable_service_endpoints  = optional(bool, false)        # Enable service endpoints (optional)(bool)
      service_endpoints         = optional(set(string))        # List of service endpoints (optional)
    }
  ))
}

variable "cogsvcs" {
  description = "list of cognitive services to deploy"
  type = object({
    allowed_ips = optional(list(string))  # list of allowed ip addresses for firewall
    services    = optional(set(string))   # list of CogServices to deploy
  })
}

variable "azSearch" {
  description = "Azure Search configuration options"
  type = object({
    sku                     = optional(string, "standard")  # Azure search SKU
    allowed_ips             = optional(list(string))        # List of allowed IPs for Search firewall
    replica_count           = optional(number, 2)           # Azure Search replica count
    partition_count         = optional(number, 2)           # Azure Search partition count
    public_access           = optional(bool, true)          # Enable / Disable public access
    enable_private_endpoint = optional(bool, false)         # Enable / Disable Private Endpoint
    create_priavte_dns_zone = optional(bool, false)         # Enable / Disable creation of private DNS zone
  })
}

variable "AppService" {
  description = "AppService and WebApp Configuration"
  type = object({
    asp_sku = string  # App Service SKU
    os_type = string  # App Service OS [Windows | Linux]
  })
}