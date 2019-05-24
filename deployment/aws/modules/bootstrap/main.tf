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

resource "aws_s3_bucket" "bootstrap_bucket" {
  bucket_prefix = "multicloud-automation-lab-"
  acl           = "private"
}

resource "aws_s3_bucket_object" "bootstrap_init_cfg" {
  bucket = "${aws_s3_bucket.bootstrap_bucket.id}"
  key    = "config/init-cfg.txt"
  source = "${var.bootstrap_init_cfg_path}"
}

resource "aws_s3_bucket_object" "bootstrap_xml" {
  bucket = "${aws_s3_bucket.bootstrap_bucket.id}"
  key    = "config/bootstrap.xml"
  source = "${var.bootstrap_xml_path}"
}

resource "aws_s3_bucket_object" "content" {
  bucket = "${aws_s3_bucket.bootstrap_bucket.id}"
  key    = "content/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "license" {
  bucket = "${aws_s3_bucket.bootstrap_bucket.id}"
  key    = "license/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "software" {
  bucket = "${aws_s3_bucket.bootstrap_bucket.id}"
  key    = "software/"
  source = "/dev/null"
}
