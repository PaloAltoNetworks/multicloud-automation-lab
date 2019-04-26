resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr}"

  tags = "${merge(map("Name", format("%s-VPC", var.name)), var.tags)}"
}

resource "aws_subnet" "mgmt" {
  count = "${length(var.mgmt_subnets) > 0 ? length(var.mgmt_subnets) : 0}"

  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(concat(var.mgmt_subnets, list("")), count.index)}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-MgmtSubnet-%s", var.name, element(var.azs, count.index))), var.tags)}"
}

resource "aws_subnet" "public" {
  count = "${length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(concat(var.public_subnets, list("")), count.index)}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-PublicSubnet-%s", var.name, element(var.azs, count.index))), var.tags)}"
}

resource "aws_subnet" "web" {
  count = "${length(var.web_subnets) > 0 ? length(var.web_subnets) : 0}"

  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(concat(var.web_subnets, list("")), count.index)}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-WebSubnet-%s", var.name, element(var.azs, count.index))), var.tags)}"
}

resource "aws_subnet" "db" {
  count = "${length(var.db_subnets) > 0 ? length(var.db_subnets) : 0}"

  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(concat(var.db_subnets, list("")), count.index)}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-DbSubnet-%s", var.name, element(var.azs, count.index))), var.tags)}"
}

resource "aws_internet_gateway" "igw" {
  count = "${length(var.public_subnets) + length(var.mgmt_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(map("Name", format("%s-IGW", var.name)), var.tags)}"
}

resource "aws_route_table" "public" {
  count = "${length(var.public_subnets) + length(var.mgmt_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(map("Name", format("%s-PublicRouteTable", var.name)), var.tags)}"
}

resource "aws_route" "public" {
  count = "${length(var.public_subnets) + length(var.mgmt_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_route_table_association" "mgmt" {
  count = "${length(var.mgmt_subnets) > 0 ? length(var.mgmt_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.mgmt.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
