variable "aws_region_name" {}

variable "ssh_key_name" {}

variable "bootstrap_bucket_name" {}

variable "allowed_mgmt_cidr" {
  default = "0.0.0.0/0"
}
