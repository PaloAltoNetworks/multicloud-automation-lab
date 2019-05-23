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

output "name" {
  value = "${var.name}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output vpc_cidr_block {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "mgmt_subnet_id" {
  value = "${aws_subnet.mgmt.id}"
}

output "mgmt_subnet_cidr_block" {
  value = "${aws_subnet.mgmt.cidr_block}"
}

output "public_subnet_id" {
  value = "${aws_subnet.public.id}"
}

output "public_subnet_cidr_block" {
  value = "${aws_subnet.public.cidr_block}"
}

output "web_subnet_id" {
  value = "${aws_subnet.web.id}"
}

output "web_subnet_cidr_block" {
  value = "${aws_subnet.web.cidr_block}"
}

output "db_subnet_id" {
  value = "${aws_subnet.db.id}"
}

output "db_subnet_cidr_block" {
  value = "${aws_subnet.db.cidr_block}"
}
