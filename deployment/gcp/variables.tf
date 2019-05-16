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
# PROJECT VARIABLES
############################################################################################
variable "project" {
  description = "Your GCP project ID"
  type = "string"
}

variable "region" {
  description = "The GCP region in which to deploy"
  type = "string"
}

variable "zone" {
  description = "The GCP zone in which to deploy"
  type = "string"
}

variable "credentials_file" {
  description = "Full path to the JSON credentials file"
  type = "string"
}

variable "public_key_file" {
  description = "Full path to the SSH public key file"
  type = "string"
}

variable "allowed_mgmt_cidr" {
  description = "The source address that will be allowed to access the lab environment"
  type = "string"
  default = "0.0.0.0/0"
}

