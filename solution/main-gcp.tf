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

resource "panos_static_route_ipv4" "outbound" {
  name           = "outbound"
  virtual_router = "${panos_virtual_router.lab_vr.name}"
  destination    = "0.0.0.0/0"
  interface      = "${panos_ethernet_interface.untrust.name}"
  next_hop       = "10.5.1.1"
}

resource "panos_static_route_ipv4" "to-web" {
  name           = "to-web"
  virtual_router = "${panos_virtual_router.lab_vr.name}"
  destination    = "10.5.2.0/24"
  interface      = "${panos_ethernet_interface.web.name}"
  next_hop       = "10.5.2.1"
}

resource "panos_static_route_ipv4" "to-db" {
  name           = "to-db"
  virtual_router = "${panos_virtual_router.lab_vr.name}"
  destination    = "10.5.3.0/24"
  interface      = "${panos_ethernet_interface.db.name}"
  next_hop       = "10.5.3.1"
}

resource "panos_zone" "untrust" {
  name       = "untrust-zone"
  mode       = "layer3"
  interfaces = ["${panos_ethernet_interface.untrust.name}"]
}

resource "panos_zone" "web" {
  name       = "web-zone"
  mode       = "layer3"
  interfaces = ["${panos_ethernet_interface.web.name}"]
}

resource "panos_zone" "database" {
  name       = "db-zone"
  mode       = "layer3"
  interfaces = ["${panos_ethernet_interface.db.name}"]
}
