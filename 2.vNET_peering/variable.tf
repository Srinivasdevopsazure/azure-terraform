variable "hub_subnet_names" {
  type    = list(string)
  default = ["HubLinuxVm"]
  #   mapping = {
  #     WebServer = "10.30.10.0/28"
  #     AppServer = "10.30.10.32/27"
  #     DbServer  = "10.30.10.64/26"
  #   }
}

variable "spoke_subnet_names" {
  type    = list(string)
  default = ["spokeLinuxVm"]
}

variable "bravo_subnet_names" {
  type    = list(string)
  default = ["BravoLinuxVm"]
}

