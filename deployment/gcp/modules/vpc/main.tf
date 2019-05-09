############################################################################################
# Copyright 2019 Palo Alto Networks.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
############################################################################################


############################################################################################
# CREATE VPCS AND SUBNETS
############################################################################################

resource "google_compute_subnetwork" "management-sub" {
	name					= "${var.vpc_mgmt_subnet_name}"
	ip_cidr_range			= "${var.vpc_mgmt_subnet_cidr}"
	network					= "${google_compute_network.management-net.self_link}"
	region					= "${var.vpc_region}"
}

resource "google_compute_network" "management-net" {
	name					= "${var.vpc_mgmt_network_name}"
	auto_create_subnetworks	= "false"
}

resource "google_compute_subnetwork" "untrust-sub" {
	name					= "${var.vpc_untrust_subnet_name}"
	ip_cidr_range			= "${var.vpc_untrust_subnet_cidr}"
	network					= "${google_compute_network.untrust-net.self_link}"
	region					= "${var.vpc_region}"
}

resource "google_compute_network" "untrust-net" {
	name					= "${var.vpc_untrust_network_name}"
	auto_create_subnetworks	= "false"
}

resource "google_compute_subnetwork" "web-sub" {
	name					= "${var.vpc_web_subnet_name}"
	ip_cidr_range			= "${var.vpc_web_subnet_cidr}"
	network					= "${google_compute_network.web-net.self_link}"
	region					= "${var.vpc_region}"
}

resource "google_compute_network" "web-net" {
	name					= "${var.vpc_web_network_name}"
	auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "db-sub" {
	name					= "${var.vpc_db_subnet_name}"
	ip_cidr_range			= "${var.vpc_db_subnet_cidr}"
	network					= "${google_compute_network.db-net.self_link}"
	region					= "${var.vpc_region}"
}

resource "google_compute_network" "db-net" {
	name					= "${var.vpc_db_network_name}"
	auto_create_subnetworks	= "false"
}



############################################################################################
# CREATE GCP FIREWALL RULES
############################################################################################

resource "google_compute_firewall" "mgmt-allow-inbound" {
	name    = "mgmt-allow-inbound"
	network = "${google_compute_network.management-net.name}"

	allow {
		protocol = "icmp"
	}

	allow {
		protocol = "tcp"
		ports    = ["443", "22"]
	}

	source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "untrust-allow-inbound" {
	name    = "untrust-allow-inbound"
	network = "${google_compute_network.untrust-net.name}"

	allow {
		protocol = "tcp"
		ports    = ["80", "22", "221", "222"]
	}

	source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "web-allow-outbound" {
	name    = "web-allow-outbound"
	network = "${google_compute_network.web-net.name}"

	allow {
		protocol = "all"
	}

	source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "db-allow-outbound" {
	name    = "db-allow-outbound"
	network = "${google_compute_network.db-net.name}"

	allow {
		protocol = "all"
	}

	source_ranges = ["0.0.0.0/0"]
}