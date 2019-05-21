data "aws_availability_zones" "azs" {
  state = "available"
}

resource "random_shuffle" "az" {
  input        = ["${data.aws_availability_zones.azs.names}"]
  result_count = 1
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr}"

  tags = "${merge(map("Name", format("%s-VPC", var.name)), var.tags)}"
}

resource "aws_subnet" "mgmt" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.mgmt_subnet}"
  availability_zone = "${var.specify_az != "0" ? var.specify_az: random_shuffle.az.result[0]}"

  tags = "${merge(map("Name", format("%s-MgmtSubnet", var.name)), var.tags)}"
}

resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.public_subnet}"
  availability_zone = "${var.specify_az != "0" ? var.specify_az : random_shuffle.az.result[0]}"

  tags = "${merge(map("Name", format("%s-PublicSubnet", var.name)), var.tags)}"
}

resource "aws_subnet" "web" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.web_subnet}"
  availability_zone = "${var.specify_az != "0" ? var.specify_az : random_shuffle.az.result[0]}"

  tags = "${merge(map("Name", format("%s-WebSubnet", var.name)), var.tags)}"
}

resource "aws_subnet" "db" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.db_subnet}"
  availability_zone = "${var.specify_az != "0" ? var.specify_az : random_shuffle.az.result[0]}"

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
