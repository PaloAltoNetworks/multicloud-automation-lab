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
# CREATE DATABASE SERVER INSTANCE
############################################################################################


resource "google_compute_instance" "dbserver" {
	name						= "${var.db_name}-${count.index + 1}"
	machine_type				= "${var.db_machine_type}"
	zone						= "${var.db_zone}"
	can_ip_forward				= true
	allow_stopping_for_update	= true
	count						= 4

	metadata {
		serial-port-enable		= true
		block-project-ssh-keys	= false
		ssh-keys				= "${var.db_ssh_key}"
	}

	labels						= {
		server-type 			= "database"
	}

	metadata_startup_script 	= "${file("../scripts/dbserver-startup.sh")}"

	service_account {
		scopes					= ["userinfo-email", "compute-ro", "storage-ro"]
	}

	network_interface {
		subnetwork				= "${var.db_subnet_id}"
	}

	boot_disk {
		initialize_params {
			image				= "${var.db_image}"
		}
	}
}