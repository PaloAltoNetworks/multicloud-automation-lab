# Firewall Terraform Module

## Usage

```terraform
module "fw_a" {
  source = "./modules/fw"

  name = "Firewall"

  ssh_key_name = "..."
  vpc_id       = "..."

  fw_mgmt_subnet_id = "..."
  fw_mgmt_ip        = "..."
  fw_mgmt_sg_id     = "..."

  fw_dataplane_subnet_ids = ["...", "..."]
  fw_dataplane_ips        = ["...", "..."]
  fw_dataplane_sg_id      = "..."
}
```

## Variables

### Required

`ssh_key_name` - SSH keypair used to provision firewall.

`vpc_id` - VPC to create firewall instance in.

`fw_mgmt_sg_id` - Security group for firewall management interface.

`fw_mgmt_subnet_id` - Subnet ID for firewall management interface.

`fw_mgmt_ip` - Internal IP address for firewall management interface.

`fw_dataplane_sg_id` - Security group for firewall dataplane interfaces.

`fw_dataplane_subnet_ids` - Subnet IDs for firewall dataplane interfaces.  A separate interface will be created for
each entry in this list.

`fw_dataplane_ips` - Internal IP addresses for the firewall dataplane interfaces.  Each entry in this list has a
corresponding entry in `fw_dataplane_subnet_ids`.

### Optional

`name` - Name of the created instance.  Created resources will be prefixed with this string (default is *Firewall*).

`fw_instance_type` - Type of firewall instance (default is *m4.xlarge*).

`fw_version` - Firewall version used to filter available AMIs (default is *8.1*).

`fw_product_code` - VM-Series product code.  Change this to select the licensing for the firewall instance (default is
*BYOL*).

- `6njl1pau431dv1qxipg63mvah` is BYOL.
- `6kxdw3bbmdeda3o6i1ggqt4km` is Bundle 1.
- `806j2of0qy5osgjjixq9gqc6g` is Bundle 2.