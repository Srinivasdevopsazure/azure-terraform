
resource "azurerm_resource_group" "dns-rg" {
  name     = "dns-rg"
  location = "East US"
}

resource "azurerm_dns_zone" "example-public" {
  name                = "sanvisolutions.xyz"
  resource_group_name = azurerm_resource_group.dns-rg.name
}


# resource "azurerm_dns_a_record" "example" {
#   name                = "test"
#   zone_name           = azurerm_dns_zone.example-public.name
#   resource_group_name = azurerm_resource_group.dns-rg.name
#   ttl                 = 300
#   records             = ["10.0.180.17"]
# }

# resource "azurerm_dns_cname_record" "example1" {
#   name                = "test1"
#   zone_name           = azurerm_dns_zone.example-public.name
#   resource_group_name = azurerm_resource_group.dns-rg.name
#   ttl                 = 300
#   record              = "contoso.com"
# }
