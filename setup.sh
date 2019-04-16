#!/usr/bin/env bash

TERRAFORM_VERSION=0.11.13

cd ${HOME}
mkdir -p ${HOME}/bin

wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS

sed -i '/.*linux_amd64.zip/!d' terraform_${TERRAFORM_VERSION}_SHA256SUMS
sha256sum -cs terraform_${TERRAFORM_VERSION}_SHA256SUMS
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d ${HOME}/bin
rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

sudo pip install ansible pan-python pandevice

ansible-galaxy install PaloAltoNetworks.paloaltonetworks