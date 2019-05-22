====================
Lab Deployment (GCP)
====================

.. warning:: If you are working on the AWS lab, skip this page and proceed to the `AWS lab deployment page <deploy-aws.html>`_.

In this activity you will:

- Create a service account credential file
- Create an SSH key-pair
- Create the Terraform variables
- Initialize the GCP Terraform provider
- Deploy the lab infrastucture plan
- Confirm firewall bootstrap completion

Create a service account credential file
----------------------------------------
We will be deploying the lab infrastucture in GCP using Terraform.  A predefined Terraform plan is provided that will initialize the GCP provider and call modules responsible for instantiating the network, compute, and storage resources needed.

In order for Terraform to do this it will need to authenticate to GCP.  We *could* authenticate to GCP using the username presented in the Qwiklabs panel when the lab was started.  However, the Compute Engine default service account is typically used because it is certain to have all the neccesary permissions.

List the email address of the Compute Engine default service account.

.. code-block:: bash

    $ gcloud iam service-accounts list

Use the following ``gcloud`` command to download the credentials for the
**Compute Engine default service account** using its associated email address
(displayed in the output of the previous command).

.. code-block:: bash

    $ gcloud iam service-accounts keys create ~/gcp_compute_key.json --iam-account <EMAIL_ADDRESS>

Verify the JSON credentials file was successfully created.

.. code-block:: bash

    $ cat ~/gcp_compute_key.json


Create an SSH key-pair
----------------------
All Compute Engine instances are required to have an SSH key-pair defined when
the instance is created.  This is done to ensure secure access to the instance
will be available once it is created.

Create an SSH key-pair with an empty passphrase and save them in the ``~/.ssh``
directory.

.. code-block:: bash

    $ ssh-keygen -t rsa -b 1024 -N '' -f ~/.ssh/lab_ssh_key

.. note:: GCP has the ability to manage all of its own SSH keys and propagate
          them automatically to projects and instances. However, the VM-Series
          is only able to make use of a single SSH key. Rather than leverage
          GCP's SSH key management process, we've created our own SSH key and
          configured Compute Engine to use our key exclusively.


Create the Terraform variables
------------------------------
Change into the GCP deployment directory.

.. code-block:: bash

    $ cd ~/multicloud-automation-lab/deployment/gcp

In this directory you will find the three main files associated with a
Terraform plan: ``main.tf``, ``variables.tf``, and ``outputs.tf``.  View the
contents of these files to see what they contain and how they're structured.

.. code-block:: bash

    $ more main.tf
    $ more variables.tf
    $ more outputs.tf

The file ``main.tf`` defines the providers that will be used and the resources
that will be created (more on that shortly).  Since it is poor practice to hard
code values into the plan, the file ``variables.tf`` will be used to declare
the variables that will be used in the plan (but not necessarily their values).
The ``outputs.tf`` file will define the values to display that result from
applying the plan.

Create a file called ``terraform.tfvars`` in the current directory that contains the following variables and their values.  Fill in the quotes with the GCP project ID, the GCP region, and GCP region, the path to the JSON credentials file, the path to your SSH public key file, and the netblock of your public IP address.

.. code-block:: bash

    project             = ""
    region              = ""
    zone                = ""
    credentials_file    = ""
    public_key_file     = ""


Initialize the GCP Terraform provider
-------------------------------------
Once you've created the ``terraform.tfvars`` file and populated it with the variables and values you are now ready to initialize the Terraform providers.  For this initial deployment we will only be using the `GCP Provider <https://www.terraform.io/docs/providers/google/index.html>`_.  This initialization process will download all the software, modules, and plugins needed for working in a particular environment.

.. code-block:: bash

    $ terraform init


Deploy the lab infrastucture plan
---------------------------------
We are now ready to deploy our lab infrastructure plan.  We should first
perform a dry-run of the deployment process and validate the contents of the
plan files and module dependencies.

.. code-block:: bash

    $ terraform plan

If there are no errors and the plan output looks good, let's go ahead and
perform the deployment.

.. code-block:: bash

    $ terraform apply -auto-approve

At a high level these are each of the steps this plan will perform:

#. Run the ``bootstrap`` module
    #. Create a GCP storage bucket for the firewall bootstrap package
    #. Apply a policy to the bucket allowing read access to ``allUsers``
    #. Create the ``/config/init-cfg.txt``, ``/config/bootstrap.xml``,
       ``/software``, ``/content``, and ``/license`` objects in the bootstrap
       bucket
#. Run the ``vpc`` module
    #. Create the VPC
    #. Create the Internet gateway
    #. Create the ``management``, ``untrust``, ``web``, and ``database``
       subnets
    #. Create the security groups for each subnet
    #. Create the default route for the ``web`` and ``database`` subnets
#. Run the ``firewall`` module
    #. Create the VM-Series firewall instance
    #. Create the VM-Series firewall interfaces
    #. Create the public IPs for the ``management`` and ``untrust`` interfaces
#. Run the ``web`` module
    #. Create the web server instance
    #. Create the web server interface
#. Run the ``database`` module
    #. Create the database server instance
    #. Create the database server interface

The deployment process should finish in a few minutes and you will be presented
with the public IP addresses of the VM-Series firewall management and untrust 
interfaces.  However, the VM-Series firewall can take up to *ten minutes* to 
complete the initial bootstrap process.

It is recommended that you read the `Configure <../03-configure/terraform/background-terraform.html>`_ section 
ahead while you wait.


Confirm firewall bootstrap completion
-------------------------------------
SSH into the firewall with the following credentials.

- **Username:** ``admin``
- **Password:** ``Ignite2019!``


.. code-block:: bash

    $ ssh admin@<firewall-ip>

Once you have logged into the firewall you can check to ensure the management
plane has completed its initialization.

.. code-block:: bash

    admin> show chassis-ready

If the response is ``yes``, you are ready to proceed with the configuration
activities.

.. note:: While it is a security best practice to use SSH keys to authenticate
          to VM instances in the cloud, we have defined a static password for
          the firewall's admin account in this lab (specifically, in the
          bootstrap package).  This is because the firewall API used by
          Terraform and Ansible cannot utilize SSH keys and must have a
          username/password or API key for authentication.

