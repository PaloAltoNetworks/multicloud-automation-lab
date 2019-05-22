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


data "aws_ami" "db_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["multicloud-aws-db-*"]
  }

  owners = ["640680520898"]
}

resource "aws_instance" "db" {
  ami           = "${data.aws_ami.db_ami.id}"
  instance_type = "t2.micro"
  count         = 4
  key_name      = "${var.ssh_key_name}"

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.db.id}"
  }

  tags = "${merge(map("Name", formatlist("%s-%s", var.name, count.index + 1)), var.tags)}"
}

resource "aws_network_interface" "db" {
  subnet_id   = "${var.subnet_id}"
  #private_ips = ["${var.private_ip}"]

  tags = "${merge(map("Name", format("%s-eth0", var.name)), var.tags)}"
}
