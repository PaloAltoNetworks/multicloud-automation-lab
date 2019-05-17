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
# CREATE VM-SERIES INSTANCE
############################################################################################

resource "google_compute_instance" "firewall" {
	name						= "${var.fw_name}"
	zone						= "${var.fw_zone}"
	machine_type				= "${var.fw_machine_type}"
	min_cpu_platform			= "${var.fw_machine_cpu}"
	can_ip_forward				= true
	allow_stopping_for_update	= true
	count						= 1

	boot_disk {
		initialize_params {
			image				= "${var.fw_image}"
		}
	}

	metadata {
		vmseries-bootstrap-gce-storagebucket = "${var.fw_bootstrap_bucket}"
		serial-port-enable		= true
		block-project-ssh-keys	= true
		ssh-keys				= "${var.fw_ssh_key}"
	}

	service_account {
		scopes = ["cloud-platform"]
	}

	network_interface {
		subnetwork				= "${var.fw_mgmt_subnet}"
		network_ip				= "${var.fw_mgmt_ip}"
		access_config {
			// Needed to get a public IP address
		}
	}

	network_interface {
		subnetwork				= "${var.fw_untrust_subnet}"
		network_ip				= "${var.fw_untrust_ip}"
		access_config {
			// Needed to get a public IP address
		}
	}

	network_interface {
		subnetwork				= "${var.fw_web_subnet}"
		network_ip				= "${var.fw_web_ip}"
	}

	network_interface {
		subnetwork				= "${var.fw_db_subnet}"
		network_ip				= "${var.fw_db_ip}"
	}
}