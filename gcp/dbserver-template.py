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

"""Creates the db server."""
COMPUTE_URL_BASE = 'https://www.googleapis.com/compute/v1/'
def GenerateConfig(context):
    """Creates the dbserver."""

    resources = [{
        'name': context.properties['name'],
        'type': 'compute.v1.instance',
        'properties': {
            'zone': context.properties['zone'],
            'machineType': ''.join([COMPUTE_URL_BASE, 'projects/', context.env['project'],
                                  '/zones/', context.properties['zone'],
                                  '/machineTypes/', context.properties['machineTypeWeb']]),
            'disks': [{
                'deviceName': 'boot',
                'type': 'PERSISTENT',
                'boot': True,
                'autoDelete': True,
              'initializeParams': {
                  'sourceImage': ''.join([COMPUTE_URL_BASE, 'projects/',
                                          'debian-cloud','/global/',
                                          'images/','family/',context.properties['imageWeb']])
                }
            }],
            'metadata': {
                'items': [
                    #{'key': 'ssh-keys', 'value': context.properties['sshkey']},
                    {'key': 'serial-port-enable','value':'1'},
                    {'key': 'startup-script-url','value': ''.join(['gs://', context.properties['bootstrapbucket'], '/dbserver-startup.sh'])}
                    ]
            },
            'serviceAccounts': [{
               'email': context.properties['serviceaccount'],
               'scopes': [
                          'https://www.googleapis.com/auth/cloud.useraccounts.readonly',
                          'https://www.googleapis.com/auth/devstorage.read_only',
                          'https://www.googleapis.com/auth/logging.write',
                          'https://www.googleapis.com/auth/monitoring.write',
                          'https://www.googleapis.com/auth/compute.readonly',
               ]}
            ],
            'networkInterfaces': [{
              'network': '$(ref.' + context.properties['db-network']+ '.selfLink)',
              'subnetwork': '$(ref.' + context.properties['db-subnet'] + '.selfLink)',
                'networkIP': '10.5.3.5'
            }]
        }
    }]
    return {'resources': resources}

