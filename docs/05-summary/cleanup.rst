===========
Cleaning Up
===========

In this activity you will:

- Destroy the lab deployment

Destroy the lab deployment
--------------------------
When deploying infrastructure in the public cloud it is important to tear it down when it is no longer needed. Otherwise you will end up paying for services that are no longer needed. We'll need to go back to the deployment directory and use Terraform to destroy the infrastructure we deployed at the start of the lab.

Change into the ``deployment`` directory.

For GCP:

.. code-block:: bash

    $ cd ~/multicloud-automation-lab/deployment/gcp


For AWS:

.. code-block:: bash

    $ cd ~/multicloud-automation-lab/deployment/aws


Tell Terraform to destroy the contents of its plan files.

.. code-block:: bash

    $ terraform destroy

.. note:: The Qwiklabs training environment will actually take care of destroying everything that we've created at the end of this lab, but it is a good habit to be aware of the cloud resources you've deployed and to destroy it when you are done with it.


