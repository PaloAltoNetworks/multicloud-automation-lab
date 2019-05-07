provider "panos" {}

resource "panos_ethernet_interface" "eth1" {
  name                      = "ethernet1/1"
  vsys                      = "vsys1"
  mode                      = "layer3"
  enable_dhcp               = true
  create_dhcp_default_route = true
}

resource "panos_ethernet_interface" "eth2" {
  name        = "ethernet1/2"
  vsys        = "vsys1"
  mode        = "layer3"
  enable_dhcp = true
}

resource "panos_ethernet_interface" "eth3" {
  name        = "ethernet1/3"
  vsys        = "vsys1"
  mode        = "layer3"
  enable_dhcp = true
}
