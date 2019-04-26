output "name" {
  value = "${var.name}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output vpc_cidr_block {
  value = "${aws_vpc.vpc.cidr_block}"
}

output azs {
  value = "${var.azs}"
}

output "mgmt_subnet_ids" {
  value = ["${aws_subnet.mgmt.*.id}"]
}

output "mgmt_subnet_cidr_blocks" {
  value = ["${aws_subnet.mgmt.*.cidr_block}"]
}

output "public_subnet_ids" {
  value = ["${aws_subnet.public.*.id}"]
}

output "public_subnet_cidr_blocks" {
  value = ["${aws_subnet.public.*.cidr_block}"]
}

output "web_subnet_ids" {
  value = ["${aws_subnet.web.*.id}"]
}

output "web_subnet_cidr_blocks" {
  value = ["${aws_subnet.web.*.cidr_block}"]
}

output "db_subnet_ids" {
  value = ["${aws_subnet.db.*.id}"]
}

output "db_subnet_cidr_blocks" {
  value = ["${aws_subnet.db.*.cidr_block}"]
}
