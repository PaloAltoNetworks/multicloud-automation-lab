provider "aws" {
  region = "${var.aws_region_name}"
}

module "vpc" {
  source = "./modules/vpc"

  name = "Multicloud-AWS"
  cidr = "10.5.0.0/16"

  azs            = ["us-east-1a"]
  mgmt_subnets   = ["10.5.0.0/24"]
  public_subnets = ["10.5.1.0/24"]
  web_subnets    = ["10.5.2.0/24"]
  db_subnets     = ["10.5.3.0/24"]

  tags {
    Environment = "Multicloud-AWS"
  }
}

module "firewall" {
  source = "./modules/firewall"

  name = "Multicloud-AWS-Firewall"

  ssh_key_name = "${var.ssh_key_name}"
  vpc_id       = "${module.vpc.vpc_id}"

  fw_mgmt_subnet_id = "${module.vpc.mgmt_subnet_ids[0]}"
  fw_mgmt_ip        = "10.5.0.4"
  fw_mgmt_sg_id     = "${aws_security_group.firewall_mgmt_sg.id}"

  fw_dataplane_subnet_ids = [
    "${module.vpc.public_subnet_ids[0]}",
    "${module.vpc.web_subnet_ids[0]}",
    "${module.vpc.db_subnet_ids[0]}",
  ]

  fw_dataplane_ips = [
    "10.5.1.4",
    "10.5.2.4",
    "10.5.3.4",
  ]

  fw_dataplane_sg_id = "${aws_security_group.public_sg.id}"

  fw_version          = "9.0"
  fw_product_code     = "806j2of0qy5osgjjixq9gqc6g"
  fw_bootstrap_bucket = "ignite2019-automation-aws"

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
  network_interface_id   = "${module.firewall.fw_dataplane_if_ids[1]}"
}

resource "aws_route_table_association" "web_assoc" {
  subnet_id      = "${module.vpc.web_subnet_ids[0]}"
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
  network_interface_id   = "${module.firewall.fw_dataplane_if_ids[2]}"
}

resource "aws_route_table_association" "db_assoc" {
  subnet_id      = "${module.vpc.db_subnet_ids[0]}"
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

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "web" {
  source = "./modules/web"

  name         = "Multicloud-AWS-Web01"
  ssh_key_name = "${var.ssh_key_name}"

  subnet_id  = "${module.vpc.web_subnet_ids[0]}"
  private_ip = "10.5.2.5"

  tags {
    Environment = "Multicloud-AWS"
  }
}

module "db" {
  source = "./modules/db"

  name         = "Multicloud-AWS-Db01"
  ssh_key_name = "${var.ssh_key_name}"

  subnet_id  = "${module.vpc.db_subnet_ids[0]}"
  private_ip = "10.5.3.5"

  tags {
    Environment = "Multicloud-AWS"
  }
}
