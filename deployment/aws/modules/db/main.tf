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
  key_name      = "${var.ssh_key_name}"

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.db.id}"
  }

  tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"
}

resource "aws_network_interface" "db" {
  subnet_id   = "${var.subnet_id}"
  private_ips = ["${var.private_ip}"]

  tags = "${merge(map("Name", format("%s-eth0", var.name)), var.tags)}"
}
