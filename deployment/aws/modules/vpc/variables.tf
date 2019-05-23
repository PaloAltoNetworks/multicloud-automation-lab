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

variable "name" {
  description = "Name of the created VPC.  Created resources will be prefixed with this string."
}

variable "az" {
  description = "The AWS availability zone in which to deploy"
}

variable "cidr" {
  description = "CIDR range for created VPC."
}

variable "mgmt_subnet" {
  description = "Management subnet address range."
}

variable "public_subnet" {
  description = "Public subnet address range."
}

variable "web_subnet" {
  description = "Web subnet address range."
}

variable "db_subnet" {
  description = "DB subnet address range."
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
