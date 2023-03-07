data "azurerm_dns_zone" "example" {
  name                = "sanvisolutions.xyz"
  resource_group_name = "dns-rg"
}


resource "azurerm_dns_a_record" "example" {
  name                = "www"
  zone_name           = data.azurerm_dns_zone.example.name
  resource_group_name = "dns-rg"
  ttl                 = 300
  records             = [azurerm_public_ip.slb-pip.ip_address]
}
