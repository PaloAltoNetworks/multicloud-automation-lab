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

// PROJECT Variables
variable "project" {
  default = "Your_Project_ID"
}

variable "region" {
  default = "Your_Project_Region"
}

variable "zone" {
  default = "Your_Project_Zone"
}

variable "public_key" {
  default = "Your_Public_Key_in_RSA_Format"
}

//  Bootstrap folder variables
variable "bootstrap_folders" {
  default = [
    "config/",
    "software/",
    "license/",
    "contents/"
  ]
}

//  Bootstrap file variables
variable "bootstrap_file" {
  default = "../../common/bootstrap/config/bootstrap.xml"
}

variable "init_file" {
  default = "../../common/bootstrap/config/init-cfg.xml"

}

// FIREWALL Variables
variable "firewall_name" {
  default = "vm-series"
}

variable "image_fw" {
  default = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-bundle2-901"
}
variable "machine_type_fw" {
  default = "n1-standard-4"
}

variable "machine_cpu_fw" {
  default = "Intel Skylake"
}

variable "bootstrap_bucket_fw" {
  default = "Your_Bootstrap_Bucket"
}

variable "interface_0_name" {
  default = "management"
}

variable "interface_1_name" {
  default = "untrust"
}

variable "scopes_fw" {
  default = [
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
}

// DB-SERVER Variables
variable "db_server_name" {
  default = "db-vm"
}

variable "machine_type_db" {
  default = "f1-micro"
}

variable "interface_3_name" {
  default = "db"
}

variable "image_db" {
  default = "debian-9"
}

variable "db_startup_script" {
  default = "../../common/startup-scripts/dbserver-startup.sh"

  // Example of string for startup bucket "gs://startup-2-tier/dbserver-startup.sh"
}

variable "scopes_db" {
  default = [
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/compute.readonly",
  ]
}

variable "ip_db" {
  default = "10.5.3.5"
}

// WEB-SERVER Vaiables
variable "web_server_name" {
  default = "web-vm"
}

variable "machine_type_web" {
  default = "f1-micro"
}

variable "interface_2_name" {
  default = "web"
}

variable "image_web" {
  default = "debian-9"
}

variable "web_startup_script" {
  default = "../../common/startup-scripts/webserver-startup.sh"

  //  Example of string for startup bucket  "gs://startup-2-tier/webserver-startup.sh"
}

variable "scopes_web" {
  default = [
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/compute.readonly",
  ]
}

variable "ip_web" {
  default = "10.5.2.5"
}
