====================
Terraform Background
====================


Terraform At a Glance
=====================

* Company: `HashiCorp <https://www.hashicorp.com/>`_
* Integration First Available: January 2018
* Configuration: HCL (HashiCorp Configuration Language)
* `PAN-OS Terraform Provider <https://www.terraform.io/docs/providers/panos/index.html>`_
* `GitHub Repo <https://github.com/terraform-providers/terraform-provider-panos>`_
* Implementation Language: golang


Configuration Overview
======================


Many Files, One Configuration
-----------------------------

Terraform allows you to split your configuration into as many files as you
wish.  Any Terraform file in the current working directory will be loaded and
concatenated with the others when you tell Terraform to apply your desired
configuration.

Local State
-----------

Terraform saves the things it has done to a local file, referred to as a
"state file".  Because state is saved locally, that means that sometimes the
local state will differ from what's actually configured on the firewall.

This is actually not a big deal, as many of Terraform's commands do a Read
operation to check the actual state against what's saved locally.  Any
changes that are found are then saved to the local state automatically.

Example Terraform Configuration
-------------------------------

Here's an example of a Terraform configuration file.  We will discuss the
parts of this config below.

.. code-block:: terraform

    variable "hostname" {
        default = "127.0.0.1"
    }

    variable "username" {
        default = "admin"
    }

    variable "password" {
        default = "admin"
    }

    provider "panos" {
        hostname = "${var.hostname}"
        username = "${var.username}"
        password = "${var.password}"
    }

    resource "panos_management_profile" "ssh" {
        name = "allow ssh"
        ssh = true
    }

    resource "panos_ethernet_interface" "eth1" {
        name = "ethernet1/1"
        vsys = "vsys1"
        mode = "layer3"
        enable_dhcp = true
        management_profile = "${panos_management_profile.ssh.name}"
    }

    resource "panos_zone" "zone1" {
        name = "L3-in"
        mode = "layer3"
        interfaces = ["ethernet1/1"]
        depends_on = ["panos_ethernet_interface.eth1"]
    }


Terminology
===========

Plan
----

A Terraform **plan** is the sum of all Terraform configuration files
in a given directory.  These files are generally written in *HCL*.

Provider
--------

A **provider** can loosely thought of to be a product (such as the Palo Alto
Networks firewall) or a service (such as AWS, Azure, or GCP).  The provider
understands the underlying API to the product or service, making individual
parts of those things available as *resources*.

Most providers require some kind of configuration in order to use.  For the
``panos`` provider, this is the authentication credentials of the firewall or
Panorama that you want to configure.

Providers are configured in a provider configuration block (e.g. -
``provider "panos" {...}``, and a plan can make use of any number of providers,
all working together.

Resource
--------

A **resource** is an individual component that a provider supports
create/read/update/delete operations for.

For the Palo Alto Networks firewall, this would be something like
an ethernet interface, service object, or an interface management profile.

Data Source
-----------

A **data source** is like a resource, but read-only.

For example, the ``panos`` provider has a
`data source <https://www.terraform.io/docs/providers/panos/d/system_info.html>`_
that gives you access to the results of ``show system info``.

Attribute
---------

An **attribute** is a single parameter that exists in either a resource or a
data source.  Individual attributes are specific to the resource itself, as to
what type it is, if it's required or optional, has a default value, or if
changing it would require the whole resource to be recreated or not.

Attributes can have a few different types:

- *String*:  ``"foo"``, ``"bar"``
- *Number*: ``7``, ``"42"`` (quoting numbers is fine in HCL)
- *List*: ``["item1", "item2"]``
- *Boolean**: ``true``, ``false``
- *Map*: ``{"key": "value"}`` (some maps may have more complex values)

Variables
---------

Terraform plans can have *variables* to allow for more flexibility.  These
variables come in two flavors:  user variables and attribute variables.
Whenever you want to use variables (or any other Terraform interpolation),
you'll be enclosing it in curly braces with a leading dollar sign: ``"${...}"``

User variables are variables that are defined in the Terraform plan file
with the ``variable`` keyword.  These can be any of the types of values that
attributes can be (default is string), and can also be configured to have
default values.  When using a user variable in your plan files, they are
referenced with ``var`` as a prefix: ``"${var.hostname}"``.  Terraform looks
for local variable values in the file ``terraform.tfvars``.

Attribute variables are variables that reference other resources or data
sources within the same plan.  Specifying a resource attribute using an
attribute variable creates an implicit dependency, covered below.

Dependencies
------------

There are two ways to tell Terraform that resource "A" needs to be created
before resource "B":  the universal *depends_on* resource parameter or an
attribute variable.  The first way, using *depends\_on*, is performed by
adding the universal parameter "depends\_on" within the dependent
resource.  The second way, using attribute variables, is performed by
referencing a resource or data source attribute as a variable:
``"${panos_management_profile.ssh.name}"``

Modules
-------

Terraform can group resources together in reusable pieces called *modules*.
Modules can have their own variables to allow for customization, and outputs so
that the resources they create can be accessed.  Both versions of this lab use
modules to group together elements for the base networking components, the
firewall, and the created instances.

For example, the AWS firewall configuration is located in
``deployment/aws/modules/firewall``.  Calling this module creates the firewall
instance, the network interfaces, and various other resources.

It can be used in another Terraform plan like this:

.. code-block:: terraform

   module "firewall" {
     source = "./modules/firewall"

     name = "vm-series"

     ssh_key_name = "${aws_key_pair.ssh_key.key_name}"
     vpc_id       = "${module.vpc.vpc_id}"

     fw_mgmt_subnet_id = "${module.vpc.mgmt_subnet_id}"
     fw_mgmt_ip        = "10.5.0.4"
     fw_mgmt_sg_id     = "${aws_security_group.firewall_mgmt_sg.id}"

     fw_eth1_subnet_id = "${module.vpc.public_subnet_id}"
     fw_eth2_subnet_id = "${module.vpc.web_subnet_id}"
     fw_eth3_subnet_id = "${module.vpc.db_subnet_id}"

     fw_dataplane_sg_id = "${aws_security_group.public_sg.id}"

     fw_version          = "9.0"
     fw_product_code     = "806j2of0qy5osgjjixq9gqc6g"
     fw_bootstrap_bucket = "${module.bootstrap_bucket.bootstrap_bucket_name}"

     tags {
       Environment = "Multicloud-AWS"
     }
   }

This calls the firewall module, and passes in values for the variables it
requires.


Common Commands
===============

The Terraform binary has many different CLI arguments that it supports.  We'll
discuss only a few of them here:

.. code-block:: bash

    $ terraform init

``terraform init`` initializes the current directory based off of the local
plan files, downloading any missing provider binaries or modules.

.. code-block:: bash

    $ terraform plan

``terraform plan`` refreshes provider/resource states and reports what changes
need to take place.

.. code-block:: bash

    $ terraform apply

``terraform apply`` refreshes provider/resource states and makes any needed
changes to the resources.

.. code-block:: bash

    $ terraform destroy

``terraform destroy`` refreshes provider/resource states and removes all
resources that Terraform created.
