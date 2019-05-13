.. multicloud-automation-lab documentation master file, created by
   sphinx-quickstart on Fri Mar 22 17:08:44 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Multi-Cloud Security Automation Lab Guide
=========================================

.. image:: ignite19-us.jpg

Welcome
-------

Welcome to the Multi-Cloud Security Automation Lab!

In this lab we will be learning how to automate the deployment and configuration of infrastructure supporting a web application within a public cloud provider.  A key element of this infrastructure is the Palo Alto Networks NGFW.  

Following the deployment, we will automate the configuration of the firewall to support and protect protect the web application.  

Lastly, we will ensure that the firewall is able to respond effectively to changes made to the application infrastructure.  You will have your choice of deploying your application in Google Cloud Platform (GCP), Amazon Web Services (AWS) or both if time permits.  

Objectives
----------
- Understand the various methods for automating the deployment of Palo Alto Networks NGFW instances in cloud environments
- Learn to use industry-leading configuration management automation tools to implement changes to PAN-OS devices
- Learn how the Palo Alto Networks NGFW can automatically respond to \ changes in the network environment


.. toctree::
   :maxdepth: 2
   :hidden:
   :caption: overview

   00-overview/introduction

.. toctree::
    :maxdepth: 2
    :hidden:
    :caption: getting started

    01-getting-started/requirements
    01-getting-started/setup

.. toctree::
    :maxdepth: 2
    :hidden:
    :caption: deploy

    02-deploy/deploy-gcp
    02-deploy/deploy-aws

.. toctree::
    :maxdepth: 2
    :hidden:
    :caption: configure

    03-configure/terraform/background-terraform
    03-configure/terraform/activities-terraform
    03-configure/ansible/background-ansible
    03-configure/ansible/activities-ansible

.. toctree::
    :maxdepth: 2
    :hidden:
    :caption: respond

    04-respond/respond

.. toctree::
    :maxdepth: 2
    :hidden:
    :caption: summary

    05-summary/summary
    05-summary/cleanup
    05-summary/moreinfo


