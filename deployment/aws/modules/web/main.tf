data "aws_ami" "web_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2-*"]
  }

  owners = ["379101102735"]
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.web_ami.id}"
  instance_type = "t2.micro"
  key_name      = "${var.ssh_key_name}"

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.web.id}"
  }

  user_data = "${var.user_data}"

  tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"
}

resource "aws_network_interface" "web" {
  subnet_id   = "${var.subnet_id}"
  private_ips = ["${var.private_ip}"]

  tags = "${merge(map("Name", format("%s-eth0", var.name)), var.tags)}"
}
