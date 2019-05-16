#!/usr/bin/env bash

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

# For use on Debian 9 (Stretch) servers

echo "Setting up student account ..."
useradd -m -s /bin/bash student
echo 'student:Ignite2019!' | chpasswd
usermod -aG sudo student

echo "Configuring SSH server for password authentication ..."
mv /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
cat /etc/ssh/sshd_config.orig | sed 's/^PasswordAuthentication no/PasswordAuthentication yes/g' > /etc/ssh/sshd_config
service sshd restart

echo "Creating .vimrc ..."
cat > /home/student/.vimrc << EOF
set ruler
set showmode
set showmatch
set tabstop=4
set shiftwidth=4
set et
set laststatus=2
set paste
EOF

echo "Installing required packages ..."
apt update -y -q
apt-get install unzip git jq python-pip -y -q

echo "Installing Ansible ..."
pip -q install pan-python pandevice xmltodict ansible
/usr/local/bin/ansible-galaxy install PaloAltoNetworks.paloaltonetworks
mv /root/.ansible /home/student

echo "Installing Terraform ..."
terraform_url=$(curl https://releases.hashicorp.com/index.json | jq '{terraform}' | egrep "linux.*amd64" | sort --version-sort -r | grep -Ev 'alpha|beta' | head -1 | awk -F[\"] '{print $4}')
cd /tmp
curl -o terraform.zip $terraform_url
unzip terraform.zip
mv terraform /usr/local/bin/
rm -f terraform.zip

echo "Fixing all permissions ..."
chown -R student:student /home/student

echo "Done with user data init!"
