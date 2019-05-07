=========
Terraform
=========

For this portion of the lab, you will be using the Palo Alto Networks 
`Terraform provider <https://www.terraform.io/docs/providers/panos/index.html>`_.

First, change to the ``exercises/01-terraform`` directory.

Provider Communication
======================

Your first task is to set up the communication between the provider and your lab firewall.  There's several ways this
can be done.  The IP address, username, and password (or API key) can be set as variables in Terraform, and can either
be typed in manually each time the Terraform plan is run, or specified on the command line using the ``-var`` command
line option.

Another way you can accomplish this is by using environment variables.  Edit the file ``envvars.sh`` with
your text editor: ::

    #!/bin/sh

    export PANOS_HOSTNAME="<YOUR FIREWALL IP ADDRESS GOES HERE>"
    export PANOS_USERNAME="admin"
    export PANOS_PASSWORD="Ignite2019!"

Replace the text ``<YOUR FIREWALL IP ADDRESS GOES HERE>`` with your firewall's management IP address.  The username and
password should still be valid if you haven't changed the bootstrap configuration.  Save the file, and export the
variables by running the following command: ::

    source envvars.sh

Now, you should see the variables exported in your shell, which you can verify using the ``env`` command: ::

    ...
    PANOS_HOSTNAME=3.216.53.203
    PANOS_USERNAME=admin
    PANOS_PASSWORD=Ignite2019!
    ...

They may not necessarily be in order, and you will see a lot of other environment variables as well, so you may have to
hunt a little bit.

The provider is now ready to communicate with our firewall.

Network Interface Configuration
===============================

Your firewall has been bootstrapped with an initial password and nothing else.  We're going to be performing the
initial networking configuration with Terraform.

You've been provided with the following Terraform plan in ``main.tf``: ::

    provider "panos" {}

    resource "panos_ethernet_interface" "eth1" {
        name                      = "ethernet1/1"
        vsys                      = "vsys1"
        mode                      = "layer3"
        enable_dhcp               = true
        create_dhcp_default_route = true
    }

    resource "panos_ethernet_interface" "eth2" {
        name        = "ethernet1/2"
        vsys        = "vsys1"
        mode        = "layer3"
        enable_dhcp = true
    }

    resource "panos_ethernet_interface" "eth3" {
        name        = "ethernet1/3"
        vsys        = "vsys1"
        mode        = "layer3"
        enable_dhcp = true
    }

This configuration creates your network interfaces.  The PAN-OS provider doesn't need any configuration specified
because it is pulling that information from the environment variables we set earlier.

Now, you can run ``terraform apply``, and the interfaces will be created on the firewall.

Virtual Router Configuration
============================

Now, you'll have to assign those interfaces to the default virtual router.  You will need the
`panos_virtual_router <https://www.terraform.io/docs/providers/panos/r/virtual_router.html>`_ resource.

The example code from that page looks like this: ::

    resource "panos_virtual_router" "example" {
        name = "my virtual router"
        static_dist = 15
        interfaces = ["ethernet1/1", "ethernet1/2"]
    }

Your version is similar, but it should have the following definition:

+---------+---------------------------------------+
| Name    | Interfaces                            |
+=========+=======================================+
| default | ethernet1/1, ethernet1/2, ethernet1/3 |
+---------+---------------------------------------+

Specifying the static distance isn't required.

Define those resources in ``main.tf``, and run ``terraform apply``.

Zone Configuration
==================

Next is creating the zones for the firewall.  You will need the
`panos_zone <https://www.terraform.io/docs/providers/panos/r/zone.html>`_ resource.

The example code from that page looks like this: ::

    resource "panos_zone" "example" {
        name = "myZone"
        mode = "layer3"
        interfaces = ["${panos_ethernet_interface.e1.name}", "${panos_ethernet_interface.e5.name}"]
        enable_user_id = true
        exclude_acls = ["192.168.0.0/16"]
    }

    resource "panos_ethernet_interface" "e1" {
        name = "ethernet1/1"
        mode = "layer3"
    }

    resource "panos_ethernet_interface" "e5" {
        name = "ethernet1/5"
        mode = "layer3"
    }

Ours can be defined similar to ``e1`` or ``e5`` in this example, but they need to have the following definition:

+--------------+-------------+
| Zone Name    | Interface   |
+==============+=============+
| untrust-zone | ethernet1/1 |
+--------------+-------------+
| web-zone     | ethernet1/2 |
+--------------+-------------+
| db-zone      | ethernet1/3 |
+--------------+-------------+

Define those resources in ``main.tf``, and run ``terraform apply``.


Committing Your Configuration
=============================

One thing you have to remember when working with Terraform is it does not have support for committing your
configuration.  To commit your configuration, you can use the following Go code, which has been provided for you in 
``commit.go``: ::

    package main

    import (
        "flag"
        "log"
        "os"

        "github.com/PaloAltoNetworks/pango"
    )

    func main() {
        var (
            hostname, username, password, apikey, comment string
            ok bool
            err error
            job uint
        )

        log.SetFlags(log.Ldate | log.Ltime | log.Lmicroseconds)

        if hostname, ok = os.LookupEnv("PANOS_HOSTNAME"); !ok {
            log.Fatalf("PANOS_HOSTNAME must be set")
        }
        apikey = os.Getenv("PANOS_API_KEY")
        if username, ok = os.LookupEnv("PANOS_USERNAME"); !ok && apikey == "" {
            log.Fatalf("PANOS_USERNAME must be set if PANOS_API_KEY is unset")
        }
        if password, ok = os.LookupEnv("PANOS_PASSWORD"); !ok && apikey == "" {
            log.Fatalf("PANOS_PASSWORD must be set if PANOS_API_KEY is unset")
        }

        flag.StringVar(&comment, "c", "", "Commit comment")
        flag.Parse()

        fw := &pango.Firewall{Client: pango.Client{
            Hostname: hostname,
            Username: username,
            Password: password,
            ApiKey: apikey,
            Logging: pango.LogOp | pango.LogAction,
        }}
        if err = fw.Initialize(); err != nil {
            log.Fatalf("Failed: %s", err)
        }

        job, err = fw.Commit(comment, true, true, false, true)
        if err != nil {
            log.Fatalf("Error in commit: %s", err)
        } else if job == 0 {
            log.Printf("No commit needed")
        } else {
            log.Printf("Committed config successfully")
        }
    }

This code reads the hostname, username, and password from the environment variables we set earlier.  You can run it
with ``go run commit.go``.