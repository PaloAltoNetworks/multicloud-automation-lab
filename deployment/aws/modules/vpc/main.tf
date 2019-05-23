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

resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr}"

  tags = "${merge(map("Name", format("%s-VPC", var.name)), var.tags)}"
}

resource "aws_subnet" "mgmt" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.mgmt_subnet}"
  availability_zone = "${var.az}"

  tags = "${merge(map("Name", format("%s-MgmtSubnet", var.name)), var.tags)}"
}

resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.public_subnet}"
  availability_zone = "${var.az}"

  tags = "${merge(map("Name", format("%s-PublicSubnet", var.name)), var.tags)}"
}

resource "aws_subnet" "web" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.web_subnet}"
  availability_zone = "${var.az}"

  tags = "${merge(map("Name", format("%s-WebSubnet", var.name)), var.tags)}"
}

resource "aws_subnet" "db" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.db_subnet}"
  availability_zone = "${var.az}"

  tags = "${merge(map("Name", format("%s-DbSubnet", var.name)), var.tags)}"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(map("Name", format("%s-IGW", var.name)), var.tags)}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(map("Name", format("%s-PublicRouteTable", var.name)), var.tags)}"
}

resource "aws_route" "public" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_route_table_association" "mgmt" {
  subnet_id      = "${aws_subnet.mgmt.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}
