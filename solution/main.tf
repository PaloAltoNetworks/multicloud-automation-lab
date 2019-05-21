provider "panos" {}

resource "panos_ethernet_interface" "eth1" {
  name                      = "ethernet1/1"
  comment					          = "untrust interface"
  vsys                      = "vsys1"
  mode                      = "layer3"
  enable_dhcp               = true
  create_dhcp_default_route = true
}

resource "panos_ethernet_interface" "eth2" {
  name						          = "ethernet1/2"
  comment 					        = "web interface"
  vsys						          = "vsys1"
  mode						          = "layer3"
  enable_dhcp				        = true
}

resource "panos_ethernet_interface" "eth3" {
  name						          = "ethernet1/3"
  comment 					        = "database interface"
  vsys						          = "vsys1"
  mode						          = "layer3"
  enable_dhcp				        = true
}

resource "panos_virtual_router" "lab_vr" {
    name 					          = "lab_vr"
    interfaces 				      = ["ethernet1/1", "ethernet1/2", "ethernet1/3"]
}

resource "panos_zone" "untrust" {
    name 					          = "untrust-zone"
    mode 					          = "layer3"
    interfaces 				      = ["${panos_ethernet_interface.eth1.name}"]
}

resource "panos_zone" "web" {
  name 					            = "web-zone"
  mode 					            = "layer3"
  interfaces 				        = ["${panos_ethernet_interface.eth2.name}"]
}

resource "panos_zone" "database" {
  name 					            = "db-zone"
  mode 					            = "layer3"
  interfaces 				        = ["${panos_ethernet_interface.eth3.name}"]
}