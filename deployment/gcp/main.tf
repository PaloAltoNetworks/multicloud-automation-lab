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


// Configure the Google Cloud provider
provider "google" {
  # credentials = "${file("Your_Credential_File.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
}

// Adding SSH Public Key in Project Meta Data
resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = "${var.public_key}"
}

// Adding bootstrap bucket to Project
resource "google_storage_bucket" "bootstrap_bucket_fw" {
  name          = "bootstrap_bucket_${var.project}"
  location      = "${var.region}"
  storage_class = "REGIONAL"
}
// Make the bootstrap bucket public
resource "google_storage_bucket_acl" "bootstrap_bucket_acl" {
  bucket = "${google_storage_bucket.bootstrap_bucket_fw.name}"
  predefined_acl = "publicread"
  depends_on    = ["google_storage_bucket.bootstrap_bucket_fw"]
}
// Make all new objects public
resource "google_storage_default_object_access_control" "public_rule" {
  bucket = "${google_storage_bucket.bootstrap_bucket_fw.name}"
  role   = "READER"
  entity = "allUsers"
  depends_on    = ["google_storage_bucket_acl.bootstrap_bucket_acl"]
}
// Adding folders to bootstrap bucket
resource "google_storage_bucket_object" "bootstrap_folders" {
  count         = "${length(var.bootstrap_folders)}"
  name          = "${element(var.bootstrap_folders, count.index)}"
  content       = "${element(var.bootstrap_folders, count.index)}"
  bucket        = "${google_storage_bucket.bootstrap_bucket_fw.name}"
  depends_on = ["google_storage_default_object_access_control.public_rule"]
}
// Added config files to bootstrap bucket
resource "google_storage_bucket_object" "bootstrap_file" {
  name          = "config/bootstrap.xml"
  source        = "${var.bootstrap_file}"
  bucket        = "${google_storage_bucket.bootstrap_bucket_fw.name}"
  depends_on = ["google_storage_default_object_access_control.public_rule"]
}
resource "google_storage_bucket_object" "init_file" {
  name          = "config/init-cfg.xml"
  source        = "${var.init_file}"
  bucket        = "${google_storage_bucket.bootstrap_bucket_fw.name}"
  depends_on = ["google_storage_default_object_access_control.public_rule"]
}

// Adding VPC Networks to Project -- MANAGEMENT
resource "google_compute_subnetwork" "management-sub" {
  name          = "management-subnet"
  ip_cidr_range = "10.5.0.0/24"
  network       = "${google_compute_network.management.self_link}"
  region        = "${var.region}"
}

resource "google_compute_network" "management" {
  name                    = "${var.interface_0_name}"
  auto_create_subnetworks = "false"
}

// Adding VPC Networks to Project -- UNTRUST
resource "google_compute_subnetwork" "untrust-sub" {
  name          = "untrust-subnet"
  ip_cidr_range = "10.5.1.0/24"
  network       = "${google_compute_network.untrust.self_link}"
  region        = "${var.region}"
}

resource "google_compute_network" "untrust" {
  name                    = "${var.interface_1_name}"
  auto_create_subnetworks = "false"
}

// Adding VPC Networks to Project -- WEB_TRUST 
resource "google_compute_subnetwork" "web-trust-sub" {
  name          = "web-subnet"
  ip_cidr_range = "10.5.2.0/24"
  network       = "${google_compute_network.web.self_link}"
  region        = "${var.region}"
}

resource "google_compute_network" "web" {
  name                    = "${var.interface_2_name}"
  auto_create_subnetworks = "false"
}

// Adding VPC Networks to Project -- DB_TRUST 
resource "google_compute_subnetwork" "db-trust-sub" {
  name          = "db-subnet"
  ip_cidr_range = "10.5.3.0/24"
  network       = "${google_compute_network.db.self_link}"
  region        = "${var.region}"
}

resource "google_compute_network" "db" {
  name                    = "${var.interface_3_name}"
  auto_create_subnetworks = "false"
}

// Adding GCP ROUTE to WEB Interface
resource "google_compute_route" "web-route" {
  name                   = "web-route"
  dest_range             = "0.0.0.0/0"
  network                = "${google_compute_network.web.self_link}"
  next_hop_instance      = "${element(google_compute_instance.firewall.*.name,count.index)}"
  next_hop_instance_zone = "${var.zone}"
  priority               = 100

  depends_on = ["google_compute_instance.firewall",
    "google_compute_network.web",
    "google_compute_network.db",
    "google_compute_network.untrust",
    "google_compute_network.management",
  ]
}

// Adding GCP ROUTE to DB Interface
resource "google_compute_route" "db-route" {
  name                   = "db-route"
  dest_range             = "0.0.0.0/0"
  network                = "${google_compute_network.db.self_link}"
  next_hop_instance      = "${element(google_compute_instance.firewall.*.name,count.index)}"
  next_hop_instance_zone = "${var.zone}"
  priority               = 100

  depends_on = ["google_compute_instance.firewall",
    "google_compute_network.web",
    "google_compute_network.db",
    "google_compute_network.untrust",
    "google_compute_network.management",
  ]
}

// Adding GCP Firewall Rules for MANGEMENT
resource "google_compute_firewall" "allow-mgmt" {
  name    = "allow-mgmt"
  network = "${google_compute_network.management.self_link}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["443", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

// Adding GCP Firewall Rules for INBOUND
resource "google_compute_firewall" "allow-inbound" {
  name    = "allow-inbound"
  network = "${google_compute_network.untrust.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["80", "22", "221", "222"]
  }

  source_ranges = ["0.0.0.0/0"]
}

// Adding GCP Firewall Rules for OUTBOUND
resource "google_compute_firewall" "web-allow-outbound" {
  name    = "web-allow-outbound"
  network = "${google_compute_network.web.self_link}"

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

// Adding GCP Firewall Rules for OUTBOUND
resource "google_compute_firewall" "db-allow-outbound" {
  name    = "db-allow-outbound"
  network = "${google_compute_network.db.self_link}"

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

// Create a new Palo Alto Networks NGFW VM-Series GCE instance
resource "google_compute_instance" "firewall" {
  name                      = "${var.firewall_name}"
  machine_type              = "${var.machine_type_fw}"
  zone                      = "${var.zone}"
  min_cpu_platform          = "${var.machine_cpu_fw}"
  can_ip_forward            = true
  allow_stopping_for_update = true
  count                     = 1

  // Adding METADATA Key Value pairs to VM-Series GCE instance
  metadata {
    vmseries-bootstrap-gce-storagebucket = "${google_storage_bucket.bootstrap_bucket_fw.url}"
    serial-port-enable                   = true
    block-project-ssh-keys               = true
    ssh-keys                             = "admin:${file("${var.public_key}")}"
  }

  service_account {
    scopes = "${var.scopes_fw}"
  }

  network_interface {
    subnetwork    = "${google_compute_subnetwork.management-sub.self_link}"
    access_config = {}
  }

  network_interface {
    subnetwork    = "${google_compute_subnetwork.untrust-sub.self_link}"
    network_ip       = "10.5.1.4"
    access_config = {}
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.web-trust-sub.self_link}"
    network_ip    = "10.5.2.4"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.db-trust-sub.self_link}"
    network_ip    = "10.5.3.4"
  }

  boot_disk {
    initialize_params {
      image = "${var.image_fw}"
    }
  }

  depends_on = [
    "google_storage_bucket.bootstrap_bucket_fw",
    "google_storage_bucket_acl.bootstrap_bucket_acl",
    "google_storage_default_object_access_control.public_rule",
    "google_storage_bucket_object.bootstrap_folders",
    "google_storage_bucket_object.bootstrap_file",
    "google_storage_bucket_object.init_file"
  ]
}

// Create a new DBSERVER instance
resource "google_compute_instance" "dbserver" {
  name                      = "${var.db_server_name}"
  machine_type              = "${var.machine_type_db}"
  zone                      = "${var.zone}"
  can_ip_forward            = true
  allow_stopping_for_update = true
  count                     = 1

  // Adding METADATA Key Value pairs to DB-SERVER 
  metadata {
    serial-port-enable = true
    ssh-keys                             = "admin:${file("${var.public_key}")}"
  }

  metadata_startup_script    = "${file(var.db_startup_script)}"

  service_account {
    scopes = "${var.scopes_db}"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.db-trust-sub.self_link}"
    network_ip    = "${var.ip_db}"
  }

  boot_disk {
    initialize_params {
      image = "${var.image_db}"
    }
  }

  depends_on = ["google_compute_instance.firewall",
    "google_compute_network.web",
    "google_compute_network.db",
    "google_compute_network.untrust",
    "google_compute_network.management",
  ]
}

// Create a new WEB SERVER instance
resource "google_compute_instance" "webserver" {
  name                      = "${var.web_server_name}"
  machine_type              = "${var.machine_type_web}"
  zone                      = "${var.zone}"
  can_ip_forward            = true
  allow_stopping_for_update = true
  count                     = 1

  // Adding METADATA Key Value pairs to WEB SERVER 
  metadata {
    serial-port-enable                  = true
    block-project-ssh-keys              = true
    ssh-keys                            = "admin:${file("${var.public_key}")}"
  }

  metadata_startup_script    = "${file(var.web_startup_script)}"

  service_account {
    scopes = "${var.scopes_web}"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.web-trust-sub.self_link}"
    network_ip    = "${var.ip_web}"
  }

  boot_disk {
    initialize_params {
      image = "${var.image_web}"
    }
  }

  depends_on = ["google_compute_instance.firewall",
    "google_compute_network.web",
    "google_compute_network.db",
    "google_compute_network.untrust",
    "google_compute_network.management",
  ]
}
