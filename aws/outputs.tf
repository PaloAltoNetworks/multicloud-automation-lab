output "firewall_mgmt_ip" {
  value = "${module.firewall.fw_mgmt_eip}"
}

output "firewall_eth1_ip" {
  value = "${module.firewall.fw_eth1_eip}"
}
