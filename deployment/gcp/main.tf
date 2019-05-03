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
# CONFIGURE THE PROVIDER AND SET AUTHENTICATION TO GCE API
############################################################################################

provider "google" {
  credentials = "${file(var.credentials_file)}"
  project     = "${var.project}"
  region      = "${var.region}"
}


############################################################################################
# CREATE BUCKET & UPLOAD VMSERIES BOOTSTRAP FILES
############################################################################################

resource "google_storage_bucket" "bootstrap_bucket" {
  name          = "bootstrap-bucket-${var.project}"
  location      = "${var.region}"
  storage_class = "REGIONAL"
  force_destroy = true
}
resource "google_storage_bucket_object" "bootstrap_xml" {
  name   = "config/bootstrap.xml"
  source = "${var.bootstrap_file}"
  bucket = "${google_storage_bucket.bootstrap_bucket.name}"
}
resource "google_storage_bucket_object" "init_cfg_xml" {
  name   = "config/init-cfg.txt"
  source = "${var.init_file}"
  bucket = "${google_storage_bucket.bootstrap_bucket.name}"
}
resource "google_storage_bucket_object" "content" {
  name   = "content/"
  source = "/dev/null"
  bucket = "${google_storage_bucket.bootstrap_bucket.name}"
}
resource "google_storage_bucket_object" "software" {
  name   = "software/"
  source = "/dev/null"
  bucket = "${google_storage_bucket.bootstrap_bucket.name}"
}
resource "google_storage_bucket_object" "license" {
  name   = "license/"
  source = "/dev/null"
  bucket = "${google_storage_bucket.bootstrap_bucket.name}"
}


############################################################################################
# CREATE VPCS AND SUBNETS
############################################################################################

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


############################################################################################
# CREATE ROUTES FOR WEB AND DB NETWORKS
############################################################################################

resource "google_compute_route" "web-route" {
  name                   = "web-route"
  dest_range             = "0.0.0.0/0"
  network                = "${google_compute_network.web.self_link}"
  next_hop_instance      = "${element(google_compute_instance.firewall.*.name,count.index)}"
  next_hop_instance_zone = "${var.zone}"
  priority               = 100

  depends_on = [
    "google_compute_instance.firewall",
    "google_compute_network.web",
    "google_compute_network.db",
    "google_compute_network.untrust",
    "google_compute_network.management",
  ]
}

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


############################################################################################
# CREATE GCP FIREWALL RULES
############################################################################################

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

resource "google_compute_firewall" "allow-inbound" {
  name    = "allow-inbound"
  network = "${google_compute_network.untrust.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["80", "22", "221", "222"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "web-allow-outbound" {
  name    = "web-allow-outbound"
  network = "${google_compute_network.web.self_link}"

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "db-allow-outbound" {
  name    = "db-allow-outbound"
  network = "${google_compute_network.db.self_link}"

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}


############################################################################################
# CREATE VM-SERIES INSTANCE
############################################################################################

resource "google_compute_instance" "firewall" {
  name                      = "${var.firewall_name}"
  machine_type              = "${var.machine_type_fw}"
  zone                      = "${var.zone}"
  min_cpu_platform          = "${var.machine_cpu_fw}"
  can_ip_forward            = true
  allow_stopping_for_update = true
  count                     = 1

  metadata {
    vmseries-bootstrap-gce-storagebucket = "${google_storage_bucket.bootstrap_bucket.name}"
    serial-port-enable                   = true
    block-project-ssh-keys               = true
    ssh-keys                             = "admin:${file("${var.public_key_file}")}"
  }

  service_account {
    scopes = ["${var.scopes_fw}"]
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
    "google_storage_bucket.bootstrap_bucket",
    "google_storage_bucket_object.bootstrap_xml",
    "google_storage_bucket_object.init_cfg_xml",
    "google_storage_bucket_object.software",
    "google_storage_bucket_object.license",
    "google_storage_bucket_object.content"
  ]
}


############################################################################################
# CREATE DATABASE SERVER INSTANCE
############################################################################################

resource "google_compute_instance" "dbserver" {
  name                      = "${var.db_server_name}"
  machine_type              = "${var.machine_type_db}"
  zone                      = "${var.zone}"
  can_ip_forward            = true
  allow_stopping_for_update = true
  count                     = 1

  metadata {
    serial-port-enable      = true
    block-project-ssh-keys  = true
    ssh-keys                = "admin:${file("${var.public_key_file}")}"
  }

  metadata_startup_script    = "${file(var.db_startup_script)}"

  service_account {
    scopes = ["${var.scopes_db}"]
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

  depends_on = [
    "google_compute_instance.firewall",
    "google_compute_network.web",
    "google_compute_network.db",
    "google_compute_network.untrust",
    "google_compute_network.management",
  ]
}


############################################################################################
# CREATE WEB SERVER INSTANCE
############################################################################################

resource "google_compute_instance" "webserver" {
  name                      = "${var.web_server_name}"
  machine_type              = "${var.machine_type_web}"
  zone                      = "${var.zone}"
  can_ip_forward            = true
  allow_stopping_for_update = true
  count                     = 1

  // Adding METADATA Key Value pairs to WEB SERVER 
  metadata {
    serial-port-enable      = true
    block-project-ssh-keys  = true
    ssh-keys                = "admin:${file("${var.public_key_file}")}"
  }

  metadata_startup_script    = "${file(var.web_startup_script)}"

  service_account {
    scopes = ["${var.scopes_web}"]
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

  depends_on = [
    "google_compute_instance.firewall",
    "google_compute_network.web",
    "google_compute_network.db",
    "google_compute_network.untrust",
    "google_compute_network.management",
  ]
}
