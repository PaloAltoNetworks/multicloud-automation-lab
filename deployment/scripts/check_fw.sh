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

while true
do
  echo "Waiting for the firewall... "
  resp=$(curl -s -S -g --insecure "https://$1/api/?type=op&cmd=<show><chassis-ready></chassis-ready></show>&key=LUFRPT1GSHhHU3FYRjY5K0k4dmZxV1BkNjhLcFJUUDA9T2lmZjU0cFhUK1UzYUFyTGJac29tNGZ5d3lybE9IMU04Q2dnNFVBSFFmK3JVSzdOV1dHMzZXREo1cGVKUU1sTA==")
  if [ $? -ne 0 ] ; then
    echo "Checking firewall... "
  fi
  echo "Response $resp" >> pan.log
  if [[ $resp == *"[CDATA[yes"* ]] ; then
    echo "The firewall is ready!"
    break
  fi
  sleep 10s
done
exit 0