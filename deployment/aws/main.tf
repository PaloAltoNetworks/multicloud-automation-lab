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

provider "aws" {
  region  = "${var.aws_region_name}"
  version = "1.53.0"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "Multicloud-AWS"
  public_key = "${file(var.public_key_file)}"
}

module "bootstrap_bucket" {
  source = "./modules/bootstrap"

  bootstrap_xml_path      = "../../common/bootstrap/config/bootstrap.xml"
  bootstrap_init_cfg_path = "../../common/bootstrap/config/init-cfg.txt"
}

module "vpc" {
  source = "./modules/vpc"

  name = "Multicloud-AWS"
  cidr = "10.5.0.0/16"
  az   = "${var.aws_az_name}"

  mgmt_subnet   = "10.5.0.0/24"
  public_subnet = "10.5.1.0/24"
  web_subnet    = "10.5.2.0/24"
  db_subnet     = "10.5.3.0/24"

  tags {
    Environment = "Multicloud-AWS"
  }
}

module "firewall" {
  source = "./modules/firewall"

  name = "vm-series"

  ssh_key_name = "${aws_key_pair.ssh_key.key_name}"
  vpc_id       = "${module.vpc.vpc_id}"

  fw_mgmt_subnet_id = "${module.vpc.mgmt_subnet_id}"
  fw_mgmt_ip        = "10.5.0.4"
  fw_mgmt_sg_id     = "${aws_security_group.firewall_mgmt_sg.id}"

  fw_eth1_subnet_id = "${module.vpc.public_subnet_id}"
  fw_eth2_subnet_id = "${module.vpc.web_subnet_id}"
  fw_eth3_subnet_id = "${module.vpc.db_subnet_id}"

  fw_dataplane_sg_id = "${aws_security_group.public_sg.id}"

  fw_version          = "9.0.1"
  fw_product_code     = "806j2of0qy5osgjjixq9gqc6g"
  fw_bootstrap_bucket = "${module.bootstrap_bucket.bootstrap_bucket_name}"

  tags {
    Environment = "Multicloud-AWS"
  }
}

resource "aws_route_table" "web" {
  vpc_id = "${module.vpc.vpc_id}"

  tags {
    Name = "${module.vpc.name}-WebRouteTable"
  }
}

resource "aws_route" "web_default" {
  route_table_id         = "${aws_route_table.web.id}"
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = "${module.firewall.fw_eth2_id}"
}

resource "aws_route_table_association" "web_assoc" {
  subnet_id      = "${module.vpc.web_subnet_id}"
  route_table_id = "${aws_route_table.web.id}"
}

resource "aws_route_table" "db" {
  vpc_id = "${module.vpc.vpc_id}"

  tags {
    Name = "${module.vpc.name}-DbRouteTable"
  }
}

resource "aws_route" "db_default" {
  route_table_id         = "${aws_route_table.db.id}"
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = "${module.firewall.fw_eth3_id}"
}

resource "aws_route_table_association" "db_assoc" {
  subnet_id      = "${module.vpc.db_subnet_id}"
  route_table_id = "${aws_route_table.db.id}"
}

resource "aws_security_group" "public_sg" {
  name        = "Public Security Group"
  description = "Wide open security group for firewall external interfaces."
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "firewall_mgmt_sg" {
  name        = "FirewallMgmtSG"
  description = "Firewall Management Security Group"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    to_port     = "22"
    from_port   = "22"
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_mgmt_cidr}"]
  }

  ingress {
    to_port     = "443"
    from_port   = "443"
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_mgmt_cidr}"]
  }

  ingress {
    to_port     = "0"
    from_port   = "8"
    protocol    = "icmp"
    cidr_blocks = ["${var.allowed_mgmt_cidr}"]
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "web" {
  source       = "./modules/web"
  name         = "web-vm"
  ssh_key_name = "${aws_key_pair.ssh_key.key_name}"
  subnet_id    = "${module.vpc.web_subnet_id}"
  private_ip   = "10.5.2.5"

  tags {
    Environment = "Multicloud-AWS"
    server-type = "web"
  }
}

module "db" {
  source       = "./modules/db"
  name         = "db-vm"
  ssh_key_name = "${aws_key_pair.ssh_key.key_name}"
  subnet_id    = "${module.vpc.db_subnet_id}"
  private_ip   = "10.5.3.5"

  tags {
    Environment = "Multicloud-AWS"
    server-type = "database"
  }
}

#module "scale" {
#  source                = "./modules/scale"
#  name                  = "db-vm"
#  ssh_key_name          = "${aws_key_pair.ssh_key.key_name}"
#  subnet_id             = "${module.vpc.db_subnet_id}"
#  tags {
#    Environment         = "Multicloud-AWS"
#    server-type         = "database"
#  }
#}

