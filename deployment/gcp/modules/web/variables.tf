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


// WEB-SERVER Variables
variable "web_name" {
	description 			= "The name of the web server instance"
	type 					= "string"
}

variable "web_zone" {
	description 			= "The GCP zone in which the web server instance will be deployed"
	type 					= "string"
}
variable "web_machine_type" {
	description 			= "The GCP machine type for the web server instance"
	type 					= "string"
}

variable "web_ssh_key" {
	description 			= "The SSH key of the web server instance admin user"
	type 					= "string"
}

variable "web_subnet_id" {
	description 			= "The subnet in which the web server instance will be deployed"
	type 					= "string"
}

variable "web_ip" {
	description 			= "The IP address of the web server instance"
	type 					= "string"
}

variable "web_image" {
	description 			= "The GCP image used to deploy the web server instance"
	type 					= "string"
}
