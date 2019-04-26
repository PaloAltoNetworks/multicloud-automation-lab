# ssh_key and service_account
#sshkey = str(context.properties['userName'].split("@")[0]) + ':ssh-rsa' + context.env['sshPubKey']
serviceaccount = "default"


# Variables
zone = "us-central1-b"
region = "us-central1"
machineTypeFw = "n1-standard-4"
machineTypeWeb = "f1-micro"

#Instances
fw_instance = "vm-series"
web_instance = "web-vm"
db_instance = "db-vm"

# Source Images
imageFw = "projects/tier-test-237921/global/images/panw-qwiklab-two-tier-901"
imageWeb = "debian-9"

# Custom VPcs and subnets
mgmt_network = "mgmt-network"
mgmt_subnet = "mgmt-subnet"
web_network = "web-network"
web_subnet = "web-subnet"
public_network = "public-network"
public_subnet = "public-subnet"
db_network = "db-network"
db_subnet = "db-subnet"

# Firewall-Rules
web_firewall = "web-firewall"
db_firewall = "db-firewall"
mgmt_firewall = "mgmt-firewall"
public_firewall = "public-firewall"

# Routes
web_route = "web-route"
db_route = "db-route"

# static_ip_configuration
# Interfaces
managemet_interface_ip = '10.5.0.4'
public_interface_ip = '10.5.1.4'
web_interface_ip = '10.5.2.4'
db_interface_ip = '10.5.3.4'

# Servers
web_server_ip = '10.5.2.5'
db_server_ip = '10.5.3.5'

# Subnets
mgmt_subnet_ip = '10.5.0.0/24'
web_subnet_ip = '10.5.2.0/24'
public_subnet_ip = '10.5.1.0/24'
db_subnet_ip = '10.5.3.0/24'

COMPUTE_URL_BASE = 'https://www.googleapis.com/compute/v1/'


def GenerateConfig(context):
    outputs = []
    resources = [
        {
            'name': fw_instance,
            'type': 'compute.v1.instance',
            'properties': {
                'zone': zone,
                'machineType': ''.join([COMPUTE_URL_BASE, 'projects/', context.env['project'],
                                        '/zones/', zone,
                                        '/machineTypes/', machineTypeFw]),
                'canIpForward': True,
                'disks': [{
                    'deviceName': 'boot',
                    'type': 'PERSISTENT',
                    'boot': True,
                    'autoDelete': True,
                    'initializeParams': {
                        'sourceImage': ''.join([COMPUTE_URL_BASE, imageFw])
                    }
                }],
                'serviceAccounts': [{
                    'email': serviceaccount,
                    'scopes': [
                        'https://www.googleapis.com/auth/cloud.useraccounts.readonly',
                        'https://www.googleapis.com/auth/devstorage.read_only',
                        'https://www.googleapis.com/auth/logging.write',
                        'https://www.googleapis.com/auth/monitoring.write',
                    ]}
                ],
                'networkInterfaces': [
                    {
                        'network': '$(ref.' + mgmt_network + '.selfLink)',
                        'accessConfigs': [{
                            'name': 'MGMT Access',
                            'type': 'ONE_TO_ONE_NAT'
                        }],
                        'subnetwork': '$(ref.' + mgmt_subnet + '.selfLink)',
                        'networkIP': managemet_interface_ip,
                    },
                    {
                        'network': '$(ref.' + public_network + '.selfLink)',
                        'accessConfigs': [{
                            'name': 'External access',
                            'type': 'ONE_TO_ONE_NAT'
                        }],
                        'subnetwork': '$(ref.' + public_subnet + '.selfLink)',
                        'networkIP': public_interface_ip,
                    },
                    {
                        'network': '$(ref.' + web_network + '.selfLink)',
                        'subnetwork': '$(ref.' + web_subnet + '.selfLink)',
                        'networkIP': web_interface_ip,
                    },
                    {
                        'network': '$(ref.' + db_network + '.selfLink)',
                        'subnetwork': '$(ref.' + db_subnet + '.selfLink)',
                        'networkIP': db_interface_ip,
                    }
                ]
            }
        },
        {
            'name': db_instance,
            'type': 'compute.v1.instance',
            'properties': {
                'zone': zone,
                'machineType': ''.join([COMPUTE_URL_BASE, 'projects/', context.env["project"],
                                        '/zones/', zone,
                                        '/machineTypes/', machineTypeWeb]),
                'disks': [{
                    'deviceName': 'boot',
                    'type': 'PERSISTENT',
                    'boot': True,
                    'autoDelete': True,
                    'initializeParams': {
                        'sourceImage': ''.join([COMPUTE_URL_BASE, 'projects/',
                                                'debian-cloud', '/global/',
                                                'images/', 'family/', imageWeb])
                    }
                }],
                'metadata': {
                    'dependsOn': [fw_instance],
                    'items': [{
                        'key': 'startup-script',
                        'value': "".join(["#!/bin/bash\n", 
                                          "while true\n",
                                          "  do\n",
                                          "   wget -q --spider http://google.com\n",
                                          "   if [[ $? -eq 0 ]]; then\n",
                                          "     echo \"************Network access succeed***************\"\n",
                                          "     break\n",
                                          "   fi\n",
                                          "     echo \">>>>>>>>>>>Network access denied<<<<<<<<<<<<<<<<<\"\n",
                                          "  sleep 10s\n",
                                          "done\n",
                                          "FW_INSTANCE=\"vm-series\"\n",
                                          "sudo exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2> sudo /dev/console) 2>&1\n",
                                          "TEMP=$(curl \"http://metadata.google.internal/computeMetadata/v1/instance/zone\" -H \"Metadata-Flavor: Google\")\n",
                                          "ZONE=$(basename $TEMP)\n",
                                          "INSTANCE_NAME=$(curl \"http://metadata.google.internal/computeMetadata/v1/instance/name\" -H \"Metadata-Flavor: Google\")\n",
                                          "DB_INSTANCE=$(basename $INSTANCE_NAME)\n",
                                          "FW_IP=$(gcloud compute instances describe $FW_INSTANCE --zone=$ZONE --format=\"value(networkInterfaces[3].networkIP)\")\n",
                                          "while true\n",
                                          "    do \n",
                                          "        resp=$(curl -s -S -g --insecure \"https://$FW_IP/api/?type=op&cmd=<show><chassis-ready></chassis-ready></show>&key=LUFRPT1reXlBaWVoVmJoSUJ4K1RPejEwMUpveFUzRWM9MFNNYTI2OWVNaGpKblB0R1JLUjYxRnRFaGFWQkgzV08wNkt6NSt3bHNZcz0=\")\n",
                                          "\techo $resp\n",
                                          "        if [[ $resp == *\"[CDATA[yes\"* ]] ; then\n",
                                          "            break\n",
                                          "        fi\n",
                                          "        sleep 10s\n",
                                          "    done\n",
                                          "while true\n",
                                          "  do\n",
                                          "   resp=$(curl -s -S -g --insecure \"https://raw.githubusercontent.com/PaloAltoNetworks/googlecloud/master/two-tier-template/ssh-to-db.cgi\")\n",
                                          "   echo $resp\n",
                                          "   if [[ $resp == *\"DB-IP-ADDRESS\"* ]] ; then\n",
                                          "     break\n",
                                          "   fi\n",
                                          "   sleep 10s\n",
                                          "  done\n",
                                          "sudo apt-get update\n",
                                          "sudo apt-get -y install debconf-utils &&\n",
                                          "echo \"mysql-server mysql-server/root_password password paloalto@123\" | sudo debconf-set-selections\n",
                                          "echo \"mysql-server mysql-server/root_password_again password paloalto@123\" | sudo debconf-set-selections\n",
                                          "DEBIAN_FRONTEND=noninteractive sudo apt-get install -y mysql-server\n",
                                          "mysql -uroot -ppaloalto@123 -e \"DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');\"\n",
                                          "mysql -uroot -ppaloalto@123 -e \"DELETE FROM mysql.user WHERE User='';\"\n",
                                          "mysql -uroot -ppaloalto@123 -e \"DELETE FROM mysql.db WHERE Db='test' OR Db='test\\\\_localhost';\"\n",
                                          "mysql -uroot -ppaloalto@123 -e \"FLUSH PRIVILEGES;\"\n",
                                          "sudo sed -i \"s/.*bind-address.*/bind-address = 0.0.0.0/\" /etc/mysql/mariadb.conf.d/50-server.cnf\n",
                                          "sudo systemctl restart mysql\n",
                                          "mysql -uroot -ppaloalto@123 -e \"CREATE DATABASE Demo;\"\n",
                                          "mysql -uroot -ppaloalto@123 -e \"CREATE USER 'demouser'@'%' IDENTIFIED BY 'paloalto@123';\"\n",
                                          "mysql -uroot -ppaloalto@123 -e \"GRANT ALL PRIVILEGES ON Demo.* TO 'demouser'@'%';\"\n",
                                          "mysql -uroot -ppaloalto@123 -e \"FLUSH PRIVILEGES;\""])},
                        # {'key': 'ssh-keys', 'value': sshkey},
                        {'key': 'serial-port-enable', 'value': '1'}
                    ]
                },
                'serviceAccounts': [{
                    'email': serviceaccount,
                    'scopes': [
                        'https://www.googleapis.com/auth/cloud.useraccounts.readonly',
                        'https://www.googleapis.com/auth/devstorage.read_only',
                        'https://www.googleapis.com/auth/logging.write',
                        'https://www.googleapis.com/auth/monitoring.write',
                        'https://www.googleapis.com/auth/compute.readonly',
                    ]}
                ],
                'networkInterfaces': [{
                    'network': '$(ref.' + db_network + '.selfLink)',
                    'subnetwork': '$(ref.' + db_subnet + '.selfLink)',
                    'networkIP': db_server_ip
                }]
            }
        },
        {
            'name': web_instance,
            'type': 'compute.v1.instance',
            'properties': {
                'zone': zone,
                'machineType': ''.join([COMPUTE_URL_BASE, 'projects/', context.env["project"],
                                        '/zones/', zone,
                                        '/machineTypes/', machineTypeWeb]),
                'disks': [{
                    'deviceName': 'boot',
                    'type': 'PERSISTENT',
                    'boot': True,
                    'autoDelete': True,
                    'initializeParams': {
                        'sourceImage': ''.join([COMPUTE_URL_BASE, 'projects/',
                                                'debian-cloud', '/global/',
                                                'images/', 'family/', imageWeb])
                    }
                }],
                'metadata': {
                    'dependsOn': [fw_instance, db_instance],
                    'items': [{
                        'key': 'startup-script',
                        'value': "".join(["#!/bin/bash\n",
                                          "while true\n",
                                          "  do\n",
                                          "   wget -q --spider http://google.com\n",
                                          "   if [[ $? -eq 0 ]]; then\n",
                                          "     echo \"************Network access succeed***************\"\n",
                                          "     break\n",
                                          "   fi\n",
                                          "     echo \">>>>>>>>>>>Network access denied<<<<<<<<<<<<<<<<<\"\n",
                                          "  sleep 10s\n",
                                          "done\n",
                                          "DB_INSTANCE='db-vm'\n",
                                          "FW_INSTANCE='vm-series'\n",
                                          "sudo exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2> sudo /dev/console) 2>&1\n",
                                          "TEMP=$(curl \"http://metadata.google.internal/computeMetadata/v1/instance/zone\" -H \"Metadata-Flavor: Google\")\n",
                                          "ZONE=$(basename $TEMP)\n",
                                          "INSTANCE_NAME=$(curl \"http://metadata.google.internal/computeMetadata/v1/instance/name\" -H \"Metadata-Flavor: Google\")\n",
                                          "WEB_INSTANCE=$(basename $INSTANCE_NAME)\n",
                                          "FW_IP=$(gcloud compute instances describe $FW_INSTANCE --zone=$ZONE --format=\"value(networkInterfaces[2].networkIP)\")\n",
                                          "FW_PublicIP=$(gcloud compute instances describe $FW_INSTANCE --zone=$ZONE --format=\"value(networkInterfaces[1].accessConfigs[0].natIP)\")\n",
                                          "DB_IP=$(gcloud compute instances describe $DB_INSTANCE --zone=$ZONE --format=\"value(networkInterfaces[0].networkIP)\")\n",
                                          "echo \"Is FW up?\"\n",
                                          "while true\n",
                                          "  do\n",
                                          "   resp=$(curl -s -S -g --insecure \"https://$FW_IP/api/?type=op&cmd=<show><chassis-ready></chassis-ready></show>&key=LUFRPT1reXlBaWVoVmJoSUJ4K1RPejEwMUpveFUzRWM9MFNNYTI2OWVNaGpKblB0R1JLUjYxRnRFaGFWQkgzV08wNkt6NSt3bHNZcz0=\")\n",
                                          "   echo $resp\n",
                                          "   if [[ $resp == *\"[CDATA[yes\"* ]] ; then\n",
                                          "     break\n",
                                          "   fi\n",
                                          "  sleep 10s\n",
                                          "done\n",
                                          "while true\n",
                                          "  do\n",
                                          "   resp=$(curl -s -S -g --insecure \"https://raw.githubusercontent.com/PaloAltoNetworks/googlecloud/master/two-tier-template/ssh-to-db.cgi\")\n",
                                          "   echo $resp\n",
                                          "   if [[ $resp == *\"DB-IP-ADDRESS\"* ]] ; then\n",
                                          "     break\n",
                                          "   fi\n",
                                          "  sleep 10s\n",
                                          "done\n",
                                          "sudo apt-get update\n",
                                          "sudo apt-get install -y apache2\n",
                                          "sudo apt-get install -y wordpress\n",
                                          "sudo ln -sf /usr/share/wordpress /var/www/html/wordpress\n",
                                          "sudo gzip -d /usr/share/doc/wordpress/examples/setup-mysql.gz\n",
                                          "while true\n",
                                          " do\n",
                                          "  resp=$(mysql -udemouser -ppaloalto@123 -h $DB_IP -e 'show databases')\n",
                                          "  if [[ $resp == *\"Demo\"* ]]; then\n",
                                          "     break\n",
                                          "  fi\n",
                                          " sleep 5s\n",
                                          "done\n",
                                          "sudo bash /usr/share/doc/wordpress/examples/setup-mysql -n Demo -t $DB_IP $DB_IP\n",
                                          "sudo sed -i \"s/define('DB_USER'.*/define('DB_USER', 'demouser');/g\" /etc/wordpress/config-$DB_IP.php\n",
                                          "sudo sed -i \"s/define('DB_PASSWORD'.*/define('DB_PASSWORD', 'paloalto@123');/g\" /etc/wordpress/config-$DB_IP.php\n",
                                          "sudo mv /etc/wordpress/config-$DB_IP.php /etc/wordpress/config-$FW_PublicIP.php\n",
                                          "sudo wget -O /usr/lib/cgi-bin/guess-sql-root-password.cgi https://raw.githubusercontent.com/PaloAltoNetworks/googlecloud/master/two-tier-template/guess-sql-root-password.cgi\n",
                                          "sudo chmod +x /usr/lib/cgi-bin/guess-sql-root-password.cgi\n",
                                          "sudo sed -i \"s/DB-IP-ADDRESS/$DB_IP/g\" /usr/lib/cgi-bin/guess-sql-root-password.cgi\n",
                                          "sudo wget -O /usr/lib/cgi-bin/ssh-to-db.cgi https://raw.githubusercontent.com/PaloAltoNetworks/googlecloud/master/two-tier-template/ssh-to-db.cgi\n",
                                          "sudo chmod +x /usr/lib/cgi-bin/ssh-to-db.cgi\n",
                                          "sudo sed -i \"s/DB-IP-ADDRESS/$DB_IP/g\" /usr/lib/cgi-bin/ssh-to-db.cgi\n",
                                          "sudo wget -O /var/www/html/sql-attack.html https://raw.githubusercontent.com/PaloAltoNetworks/googlecloud/master/two-tier-template/sql-attack.html\n",
                                          "sudo ln -sf /etc/apache2/conf-available/serve-cgi-bin.conf /etc/apache2/conf-enabled/serve-cgi-bin.conf\n",
                                          "sudo ln -sf /etc/apache2/mods-available/cgi.load /etc/apache2/mods-enabled/cgi.load\n",
                                          "sudo systemctl restart apache2"])},

                        # {'key': 'ssh-keys', 'value': sshkey},
                        {'key': 'serial-port-enable', 'value': '1'}]
                },
                'serviceAccounts': [{
                    'email': serviceaccount,
                    'scopes': [
                        'https://www.googleapis.com/auth/cloud.useraccounts.readonly',
                        'https://www.googleapis.com/auth/devstorage.read_only',
                        'https://www.googleapis.com/auth/logging.write',
                        'https://www.googleapis.com/auth/monitoring.write',
                        'https://www.googleapis.com/auth/compute.readonly',
                    ]}
                ],
                'networkInterfaces': [{
                    'network': '$(ref.' + web_network + '.selfLink)',
                    'subnetwork': '$(ref.' + web_subnet + '.selfLink)',
                    'networkIP': web_server_ip
                }]
            }
        },
        {
            'name': web_network,
            'type': 'compute.v1.network',
            'properties': {
                'autoCreateSubnetworks': False,
            }
        },
        {
            'name': web_subnet,
            'type': 'compute.v1.subnetwork',
            'properties': {
                'ipCidrRange': web_subnet_ip,
                'region': region,
                'network': '$(ref.' + web_network + '.selfLink)',
            }
        },
        {
            'name': mgmt_network,
            'type': 'compute.v1.network',
            'properties': {
                'autoCreateSubnetworks': False,
            }
        },
        {
            'name': mgmt_subnet,
            'type': 'compute.v1.subnetwork',
            'properties': {
                'ipCidrRange': mgmt_subnet_ip,
                'region': region,
                'network': '$(ref.' + mgmt_network + '.selfLink)',
            }
        },
        {
            'name': public_network,
            'type': 'compute.v1.network',
            'properties': {
                'autoCreateSubnetworks': False,
            }
        },
        {
            'name': public_subnet,
            'type': 'compute.v1.subnetwork',
            'properties': {
                'ipCidrRange': public_subnet_ip,
                'region': region,
                'network': '$(ref.' + public_network + '.selfLink)',
            }
        },

        {
            'name': db_network,
            'type': 'compute.v1.network',
            'properties': {
                'autoCreateSubnetworks': False,

            }
        },
        {
            'name': db_subnet,
            'type': 'compute.v1.subnetwork',
            'properties': {
                'ipCidrRange': db_subnet_ip,
                'region': region,
                'network': '$(ref.' + db_network + '.selfLink)',
            }
        },
        {
            'metadata': {
                'dependsOn': [mgmt_network, db_network, web_network, public_network]
            },
            'name': mgmt_firewall,
            'type': 'compute.v1.firewall',
            'properties': {
                'region': region,
                'network': '$(ref.' + mgmt_network + '.selfLink)',
                'direction': 'INGRESS',
                'priority': 1000,
                'sourceRanges': ['0.0.0.0/0'],
                'allowed': [{
                    'IPProtocol': 'tcp',
                    'ports': [22, 443]
                }]
            }
        },
        {
            'metadata': {
                'dependsOn': [mgmt_network, db_network, web_network, public_network]
            },
            'name': public_firewall,
            'type': 'compute.v1.firewall',
            'properties': {
                'region': region,
                'network': '$(ref.' + public_network + '.selfLink)',
                'direction': 'INGRESS',
                'priority': 1000,
                'sourceRanges': ['0.0.0.0/0'],
                'allowed': [{
                    'IPProtocol': 'tcp',
                    'ports': [80, 221, 222]
                }]
            }
        },
        {
            'metadata': {
                'dependsOn': [mgmt_network, db_network, web_network, public_network]
            },
            'name': web_firewall,
            'type': 'compute.v1.firewall',
            'properties': {
                'region': region,
                'network': '$(ref.' + web_network + '.selfLink)',
                'direction': 'INGRESS',
                'priority': 1000,
                'sourceRanges': ['0.0.0.0/0'],
                'allowed': [{
                    'IPProtocol': 'tcp',
                }, {
                    'IPProtocol': 'udp',
                }, {
                    'IPProtocol': 'icmp'
                }]
            }
        },
        {
            'metadata': {
                'dependsOn': [mgmt_network, db_network, web_network, public_network]
            },
            'name': db_firewall,
            'type': 'compute.v1.firewall',
            'properties': {
                'region': region,
                'network': '$(ref.' + db_network + '.selfLink)',
                'direction': 'INGRESS',
                'priority': 1000,
                'sourceRanges': ['0.0.0.0/0'],
                'allowed': [{
                    'IPProtocol': 'tcp',
                }, {
                    'IPProtocol': 'udp',
                }, {
                    'IPProtocol': 'icmp'
                }]
            }
        },
        {
            'metadata': {
                'dependsOn': [mgmt_network, db_network, web_network, public_network]
            },
            'name': web_route,
            'type': 'compute.v1.route',
            'properties': {
                'priority': 100,
                'network': '$(ref.' + web_network + '.selfLink)',
                'destRange': '0.0.0.0/0',
                'nextHopIp': '$(ref.' + fw_instance + '.networkInterfaces[2].networkIP)'
            }
        },
        {
            'metadata': {
                'dependsOn': [mgmt_network, db_network, web_network, public_network]
            },
            'name': db_route,
            'type': 'compute.v1.route',
            'properties': {
                'priority': 100,
                'network': '$(ref.' + db_network + '.selfLink)',
                'destRange': '0.0.0.0/0',
                'nextHopIp': '$(ref.' + fw_instance + '.networkInterfaces[3].networkIP)'
            }
        }

    ]
    outputs.append({'name': 'Web-Server-PublicIP-Address',
                    'value': '$(ref.' + fw_instance + '.networkInterfaces[1].accessConfigs[0].natIP)'})
    outputs.append({'name': 'PANFirewall-PublicIP-Address',
                    'value': '$(ref.' + fw_instance + '.networkInterfaces[0].accessConfigs[0].natIP)'})

    return {'resources': resources, 'outputs': outputs}