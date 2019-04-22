# Copyright 2016 Google Inc. All rights reserved.
# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Creates the virtual machine."""
COMPUTE_URL_BASE = 'https://www.googleapis.com/compute/v1/'
def GenerateConfig(context):
  """Creates the first virtual machine."""
  resources = [{
      'name': context.properties['name'],
      'type': 'compute.v1.instance',
      'properties': {
          'zone': context.properties['zone'],
          'machineType': ''.join([COMPUTE_URL_BASE, 'projects/', context.env['project'],
                                  '/zones/', context.properties['zone'],
                                  '/machineTypes/', context.properties['machineType']]),
          'canIpForward': True,
          'disks': [{
              'deviceName': 'boot',
              'type': 'PERSISTENT',
              'boot': True,
              'autoDelete': True,
              'initializeParams': {
                  'sourceImage': ''.join([COMPUTE_URL_BASE, 'projects/',
                                          'paloaltonetworksgcp-public','/global/',
                                          'images/',context.properties['image']])
              }
          }],
          'metadata': {
              'items': [{'key': 'vmseries-bootstrap-gce-storagebucket','value': context.properties['bootstrapbucket']},
                        #{'key': 'ssh-keys','value':context.properties['sshkey']},
                        {'key': 'serial-port-enable','value':'1'}]
          },
          'serviceAccounts': [{
               'email': context.properties['serviceaccount'],
               'scopes': [
                          'https://www.googleapis.com/auth/cloud.useraccounts.readonly',
                          'https://www.googleapis.com/auth/devstorage.read_only',
                          'https://www.googleapis.com/auth/logging.write',
                          'https://www.googleapis.com/auth/monitoring.write',
               ]}
          ],
          'networkInterfaces': [
          {
              'network': '$(ref.' + context.properties['mgmt-network']+ '.selfLink)',
              'accessConfigs': [{
                  'name': 'MGMT Access',
                  'type': 'ONE_TO_ONE_NAT'
              }],
              'subnetwork': '$(ref.' + context.properties['mgmt-subnet'] + '.selfLink)',
              'networkIP': '10.5.0.4',
          },
        {
              'network': '$(ref.' + context.properties['untrust-network']+ '.selfLink)',
              'accessConfigs': [{
                  'name': 'External access',
                  'type': 'ONE_TO_ONE_NAT'
              }],
              'subnetwork': '$(ref.' + context.properties['untrust-subnet'] + '.selfLink)',
               'networkIP': '10.5.1.4',
          },
          {
              'network': '$(ref.' + context.properties['web-network']+ '.selfLink)',
              'subnetwork': '$(ref.' + context.properties['web-subnet'] + '.selfLink)',
              'networkIP': '10.5.2.4'
          },
          {
              'network': '$(ref.' + context.properties['db-network']+ '.selfLink)',
              'subnetwork': '$(ref.' + context.properties['db-subnet'] + '.selfLink)',
               'networkIP': '10.5.3.4',
          }
          ]
      }
  }]
  return {'resources': resources}
