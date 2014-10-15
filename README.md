## Ansible Playbook | Lxr Deployment - Nupic.core
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/h2suzuki/ansible-lxr-nupic.core?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This playbook deploys Lxr Source Code Indexer and Cross-referencer.  Then, it downloads the target source tree from github and indexing it for identifier / free-text search.

This playbook is tested with:

 - Ansible 1.7-1
 - CentOS 6.5, CentOS 7

This playbook can index any git repository that "ctag" can handle, but the configuration file is set to index [nupic.core](https://github.com/numenta/nupic.core) because it is the purpose of this project. See "group_vars/lxr-servers" for the configurations and "roles/lxr/defaults/main.yml" for the default values.


## Instructions

Firstly edit the "hosts" inventory file to indicate the machines where you want to deploy Lxr.  Secondly edit the "group_vars/lxr-servers" file to set the configuration parameters such as the web server url.

Then, setup the ssh remote login via root to your target machine:

        ssh-copy-id root@<your_machine_address>

Then, run the playbook like the below:

        ansible-playbook -i hosts site.yml

When the playbook run completes, you should be able to explore the target source tree on the URL which is indicated by "group_vars/lxr-servers".

        http://{{ httpd_server_name }}:{{ httpd_port }}/lxr/{{ lxr_tree_name }}/source

In case the target machine has SELinux running, the playbook will stop and ask you to reboot the machine to **disable SELinux**.  Run the playbook again.  The playbook will resume the operations.



## Some internals

 - This playbook consists of three phases (using tags):

   1. setup phase: install and configure Lxr on the target machine
   2. tree_retrieval phase: store the source tree in Lxr's internal directory
   3. indexing phase: index the source tree for cross-referencing & searching

 - This playbook uses root on the target machine:

   In order to setup the target machine, the playbook requires root ssh login.  It will create `lxr_user` user during the setup phase.

   For tree_retrieval and indexing phases, the playbook uses `lxr_user` user only which has been created during setup phase.



## Other usages

There are several useful tags that you can use after the initial setup.

When the target repository has a new commit and you want to **add that new version** of the source tree to be index, just run:

        ansible-playbook -i hosts site.yml --tags retrieve_source,indexing

or by the reversed way:

        ansible-playbook -i hosts site.yml --skip-tags setup

To retrieve and index a specific version of source tree, edit `lxr_tag_vcs` in "group_vars/lxr-servers". Then, run the above command. Optionally, you can override the version name shown on the browser by defining `lxr_tag_name` in the configuration file.

You can also pass `lxr_tag_name` and `lxr_tag_vcs` using "-e" command line option, if you don't want to edit the configuration file.

        ansible-playbook -i hosts site.yml --tags tree_retrieval,indexing \
          -e 'lxr_tag_name=v1.1-8f0d lxr_tag_vcs=8f0d...(40-digit sha1 omitted)'

To list the versions of the tree, specify `list_tree_tags`.

        ansible-playbook -i hosts site.yml --tags list_tree_tags

To index the tree with special parameters to be supplied to Lxr `genxref` command, use `lxr_genref_opts`.  The below example performes garbage collection by dropping unreferenced data from DB.

        ansible-playbook -i hosts site.yml --tags indexing \
          -e 'lxr_genref_opts="--reindexall --allversions"'

During setup phase, you can skip OS tweaking and package checks by "--skip-tags os_settings" option.

        ansible-playbook -i hosts site.yml --tags setup --skip-tags os_settings


## Uninstalling Lxr

Three things you need to do in order to uninstall the deployed Lxr service.

 - remove `lxr_user` and its home.  e.g. `userdel -r lxruser`
 - remove Lxr's httpd configuration file. c.f. `httpd_lxr_conf`
 - revert the changes on the httpd main configuration file: ServerName and Listen

To uninstall the packages that this playbook has installed for the requirements, see "roles/lxr/setup/tasks/020-install_pkgs.yml" for the package names.


## Additional references

 - [Ansible@github](https://github.com/ansible/ansible) / [Ansible Docs](http://docs.ansible.com/)
 - [Lxr@sourceforge.net](http://sourceforge.net/projects/lxr/) / [Lxr web-site](http://lxr.sourceforge.net/en/index.shtml)
 - [Glimpse Home](http://webglimpse.net/)
 - [Nupic.core@github](https://github.com/numenta/nupic.core)

