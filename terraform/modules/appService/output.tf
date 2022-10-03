output "asp_public_ip" {
  value = azurerm_windows_web_app.app.outbound_ip_address_list
}