===============
Tool Comparison
===============
At this point, you've now used both Ansible and Terraform to configure a Palo
Alto Networks firewall. Though you've used these two tools to deploy the same
configuration, they differ in some important ways. Let's discuss some of those
differences now.

Strengths
----------
Both tools have a certain reputation associated with them. Terraform is known
more for its power in deployment, while Ansible is known more for its
flexibility in configuration. Both products can do both jobs just fine.

Regardless of their reputations, the most important part is that Palo Alto
Networks has integrations with both, and either way will get the job done.
It's just a matter of preference.

Idempotence
-----------
Both Terraform and Ansible support `idempotent <https://en.wikipedia.org/wiki/Idempotence>`_ operations. Saying that an
operation is idempotent means that applying it multiple times will not change
the result. This is important for automation tools because they can be run to
change configuration **and** also to verify that the configuration actually
matches what you want. You can run ``terraform apply`` continuously for hours,
and if your configuration matches what is defined in the plan, it won't
actually change anything.

Commits
-------
As you've probably noticed, a lot of the Ansible modules allow you to commit
directly from them. There is also a dedicated Ansible module that just does
commits, containing support for both the firewall and Panorama.

So how do you perform commits with Terraform? Currently, there is no support
for commits inside the Terraform ecosystem, so they have to be handled
externally. Lack of finalizers are `a known shortcoming <https://github.com/hashicorp/terraform/issues/6258>`_ for Terraform and, once
it is addressed, support for it can be added to the provider. In the meantime,
we've provides some Golang code in the appendix
(:doc:`../06-appendix/terraform-commit`) that you can use to fill the gap.

Operational Commands
--------------------
Ansible currently has a ``panos_op`` module allows users to run arbitrary
operational commands. An operational command could be something that just
shows some part of the configuration, but it can also change configuration.
Since Ansible doesn't store state, it doesn't care what the invocation of the
``panos_op`` module results in.

This is a different story in Terraform. The basic flow of Terraform is that
there is a read operation that determines if a create, update, or delete needs
to take place. But operational commands as a whole don't fit as neatly into
this paradigm. What if the operational command is just a read? What if the
operational command makes a configuration change, and should only be executed
once? This uncertainty is why support for operational commands in Terraform is
not currently in place.

Facts / Data Sources
--------------------
Terraform may not have support for arbitrary operational commands, but it does
have a data source that you can use to retrieve specific parts of a ``show
system info`` command from the firewall or Panorama and then use that in your
Terraform plan file. This same thing is called "facts" in Ansible. Many of the
Ansible modules for PAN-OS support the gathering of facts that may be stored
and referenced in an Ansible playbook.
