provider "panos" {}

resource "panos_ethernet_interface" "untrust" {
  name                      = "ethernet1/1"
  comment                   = "untrust interface"
  vsys                      = "vsys1"
  mode                      = "layer3"
  enable_dhcp               = true
  create_dhcp_default_route = true
}

resource "panos_ethernet_interface" "web" {
  name        = "ethernet1/2"
  comment     = "web interface"
  vsys        = "vsys1"
  mode        = "layer3"
  enable_dhcp = true
}

resource "panos_ethernet_interface" "db" {
  name        = "ethernet1/3"
  comment     = "database interface"
  vsys        = "vsys1"
  mode        = "layer3"
  enable_dhcp = true
}

resource "panos_virtual_router" "lab_vr" {
  name = "default"

  interfaces = [
    "${panos_ethernet_interface.untrust.name}",
    "${panos_ethernet_interface.web.name}",
    "${panos_ethernet_interface.db.name}",
  ]
}

resource "panos_zone" "untrust_zone" {
  name       = "untrust-zone"
  mode       = "layer3"
  interfaces = ["${panos_ethernet_interface.untrust.name}"]
}

resource "panos_zone" "web_zone" {
  name       = "web-zone"
  mode       = "layer3"
  interfaces = ["${panos_ethernet_interface.web.name}"]
}

resource "panos_zone" "db_zone" {
  name       = "db-zone"
  mode       = "layer3"
  interfaces = ["${panos_ethernet_interface.db.name}"]
}
