variable "subnet_names" {
  type    = list(string)
  default = ["WebServer", "AppServer", "DbServer"]
  #   mapping = {
  #     WebServer = "10.30.10.0/28"
  #     AppServer = "10.30.10.32/27"
  #     DbServer  = "10.30.10.64/26"
  #   }
}

