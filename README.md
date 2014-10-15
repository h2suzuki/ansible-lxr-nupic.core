## Ansible Playbook | Lxr Deployment - Nupic.core
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/h2suzuki/ansible-lxr-nupic.core?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This playbook deploys Lxr Source Code Indexer and Cross-referencer.  Then, it downloads the target source tree from github and indexing it for identifier / free-text search.

This playbook is tested for the controller and the target machines with:

 - Ansible 1.7-1
 - CentOS 6.5, CentOS 7

This playbook can index any git repository that "ctag" can handle, but the configuration file is set to index [nupic.core](https://github.com/numenta/nupic.core) because it is the purpose of this project.


## Instructions

Firstly edit the "hosts" inventory file to indicate the machines where you want to deploy Lxr.  Secondly edit the "group_vars/lxr-servers" file to set the configuration parameters such as the web server url.

Then, run the playbook like the below:

        ansible-playbook -i hosts site.yml

When the playbook run completes, you should be able to explore the target source tree on the web server url, which is indicated by "group_vars/lxr-servers".

        http://{{ httpd_server_name }}:{{ httpd_port }}/lxr/{{ lxr_tree_name }}/source


## Special notes

 - This playbook **disables SELinux** on the target machine, and you may be asked to reboot the machine.  After the reboot, run the playbook again.  The playbook confirms that SELinux is off and continues its setup.

 - This playbook consists of three phases (using tags):

   1. the setup phase: install and configure Lxr on the target machine
   2. the tree_retrieval phase: store the source tree in Lxr's internal directory
   3. the indexing phase: index the source tree for cross-referencing & searching

   In order to setup the target machine, the playbook requires root ssh login.  It will create `lxr_user` user during the setup phase.  After that, it only uses `lxr_user` user to retrieve and index the source tree.


## Other usages

There are several useful tags that you can use after the installation.

To add another version of the source tree, edit `lxr_tag_name`(for browsing) and `lxr_tag_vcs`(for checkout) in "group_vars/lxr-servers".  Then, run the playbook again with the following tags.

        ansible-playbook -i hosts site.yml --tags retrieve_source,indexing

You can also pass `lxr_tag_name` and `lxr_tag_vcs` using "-e" command line option, so you don't need to edit the file.

        ansible-playbook -i hosts site.yml --tags tree_retrieval,indexing \
          -e 'lxr_tag_name=v1.1-8f0d lxr_tag_vcs=8f0d...(40-digit sha1 omitted)'

To list the tree versions on the browser, specify `list_tree_tags`.

        ansible-playbook -i hosts site.yml --tags list_tree_tags

To run indexing again, with special parameters of Lxr `genxref` command, use `lxr_genref_opts`.  The below example performes garbage collection by droping unreferenced data from DB.

        ansible-playbook -i hosts site.yml --tags indexing \
          -e 'lxr_genref_opts="--reindexall --allversions"'

During setup, you can skip OS tweaking (such as firewall setting) and package checks by "--skip-tags os_settings" option.

        ansible-playbook -i hosts site.yml --tags setup --skip-tags os_settings


## Uninstalling Lxr

Three things you need to do in order to uninstall the deployed lxr service.

 - remove `lxr_user` and its home.  e.g. `userdel -r lxruser`
 - remove Lxr's httpd configuration file. c.f. `httpd_lxr_conf`
 - revert the changes on the httpd main configuration file: ServerName and Listen

To uninstall the packages that this playbook has installed for the requirements, see "roles/lxr/setup/tasks/020-install_pkgs.yml" for the package names.


## Additional references

 - [Ansible@github](https://github.com/ansible/ansible) / [Ansible Docs](http://docs.ansible.com/)
 - [Lxr@sourceforge.net](http://sourceforge.net/projects/lxr/) / [Lxr web-site](http://lxr.sourceforge.net/en/index.shtml)
 - [Glimpse Home](http://webglimpse.net/)
 - [Nupic.core@github](https://github.com/numenta/nupic.core)

