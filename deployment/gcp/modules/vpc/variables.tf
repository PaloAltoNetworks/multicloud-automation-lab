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


variable "vpc_region" {
  description = "GCP region in which to deploy the network resources"
}

variable "vpc_mgmt_network_name" {
  description = "Management network name"
}

variable "vpc_mgmt_subnet_cidr" {
  description = "Management subnet netblock"
}

variable "vpc_mgmt_subnet_name" {
  description = "Management subnet name"
}

variable "vpc_untrust_network_name" {
  description = "Untrust network name"
}
variable "vpc_untrust_subnet_cidr" {
  description = "Untrust subnet netblock"
}

variable "vpc_untrust_subnet_name" {
  description = "Untrust subnet name"
}

variable "vpc_web_network_name" {
  description = "Web network name"
}

variable "vpc_web_subnet_cidr" {
  description = "Web subnet netblock"
}

variable "vpc_web_subnet_name" {
  description = "Web subnet name"
}

variable "vpc_db_network_name" {
  description = "Database network name"
}

variable "vpc_db_subnet_cidr" {
  description = "Database subnet netblock"
}

variable "vpc_db_subnet_name" {
  description = "Database subnet name"
}
