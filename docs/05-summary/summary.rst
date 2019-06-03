=======
Summary
=======

Congratulations!  You have completed the hands-on workshop.  If you only
completed the lab activities for one of the public cloud providers you are
welcome to run back through the activities in the other cloud provider
environment.  What you'll find is that (with a few cloud-specific
exceptions) the methods used to deploy and configure the VM-Series firewall
are essentially the same.

What We've Accomplished
-----------------------
We've covered all three categories of network security automation:

- **Build:** We used Terraform to orchestrate the deployment of the lab
  environment.  Rather than utilizing cloud-specific deployment tools such as
  AWS CloudFormation or Google Deployment Manager, we were able to use a common
  tool for both environments.
- **Run:** We used both Terraform and Ansible for configuring the VM-Series
  firewall instance.  Both tools leverage the PAN-OS XML API and have libraries
  that allow those tools to communicate with the API.
- **Respond:** We leveraged two PAN-OS features, VM Information Sources and
  Dynamic Address Groups, to identify changes in the cloud provider environment
  and automatically adapt to those changes.
  