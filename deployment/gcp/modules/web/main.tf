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
# CREATE WEB SERVER INSTANCE
############################################################################################

resource "google_compute_instance" "webserver" {
	name						= "${var.web_name}"
	zone						= "${var.web_zone}"
	machine_type				= "${var.web_machine_type}"
	can_ip_forward				= true
	allow_stopping_for_update	= true
	count						= 1

	// Adding METADATA Key Value pairs to WEB SERVER 
	metadata {
		serial-port-enable      = true
		block-project-ssh-keys  = true
		ssh-keys                = "${var.web_ssh_key}"
	}

	metadata_startup_script 	= "${file("../scripts/webserver-startup.sh")}"

	service_account {
		scopes                  = ["userinfo-email", "compute-ro", "storage-ro"]
	}

	network_interface {
		subnetwork              = "${var.web_subnet_id}"
		network_ip              = "${var.web_ip}"
	}

	boot_disk {
		initialize_params {
			image				= "${var.web_image}"
		}
	}
}