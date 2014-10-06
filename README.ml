## Lxr Source Code Indexer and Cross-referencer Deployment

This playbook deploys a Lxr web server. Then, it downloads the target source tree from github and indexing it for identifier / freetext search.

This playbook is tested with:

- Ansible 1.7 or newer
- CentOS 6.5 hosts


## Instructions

Firstly edit the "hosts" inventory file to indicate the machines where you want to deploy Lxr.  Secondly edit the "group_vars/lxr-servers" file to set the configuration parameters such as the web server url.  If you're granted to use glimpse for free text searching, change the value of `lxr_use_search_engine` to "glimpse".

Then, run the playbook like the below:

	ansible-playbook -i hosts site.yml

When the playbook run completes, you should be able to explore the target source tree on the web server url indicated by "group_vars/lxr-servers".

        http://{{ httpd_server_name }}/lxr/{{ lxr_tree_name }}/source


## Special notes

1. This playbook *disables SELinux* on the target machine, and you may be asked to reboot the machine.  After the reboot, run the playbook again.  The playbook confirms that SELinux is off and continues its setup.

2. This playbook is split to three phases (roles and tags):

 - the setup phase: install and configure Lxr on the target machine
 - the tree_retrieval phase: store the source tree in Lxr's internal directory
 - the indexing phase: index the source tree for cross-referencing & searching

In order to setup the target machine for Lxr, the playbook requires ssh login via root.  It will create `lxr_user` user during the setup phase.  After that, it uses `lxr_user` user only to obtain and index the source tree.

3. For free text searching, this playbook can install glimpse for you.  Glimpse requires a proper license.  If you have the license to use glimpse, or you're qualified for any license-free usage, you can change `lxr_use_search_engine` in "group_vars/lxr-servers" to enable it.

See Also: http://webglimpse.net/sublicensing/licensing.html


## Other usages

There are several useful tags that you can use after the installation.

In order to add another version of the source tree, edit `lxr_tag_name`(for browsing) and `lxr_tag_vcs`(for checkout) in "group_vars/lxr-servers".  Then, run the playbook again like the below.

	ansible-playbook -i hosts site.yml --tags retrieve_source,indexing

You can also pass `lxr_tag_name` and `lxr_tag_vcs` using "-e" instead of "group_vars/lxr-servers".

        ansible-playbook -i hosts site.yml --tags tree_retrieval,indexing \
        -e 'lxr_tag_name=v1.1/8f0d lxr_tag_vcs=8f0d...(40-digit sha1 omitted)'

To list the tree versions on the browser, specify `list_tree_tags`.

        ansible-playbook -i hosts site.yml --tags list_tree_tags

To run indexing again, with special parameters for Lxr `genxref` command such as index cleanup (i.e. garbage collection), do the below.

        ansible-playbook -i hosts site.yml --tags indexing \
        -e 'lxr_genref_opts="--reindexall --allversions"'

During setup, you can skip OS tweaking (firewall so forth) and package requirement checks by `os_settings` tag.

        ansible-playbook -i hosts site.yml --tags setup --skip-tags os_settings


## Uninstall the lxr server

Three things you need to do in order to uninstall the deployed lxr service.

 - remove lxr_user.  e.g. `userdel -r lxruser`
 - remove Lxr's httpd configuration file added: `httpd_lxr_conf`
 - revert the httpd main configuration file by hand: ServerName and Listen

Additionally you may want to uninstall the packages that this playbook installed for Lxr.  See "roles/lxr/setup/tasks/020-install_pkgs.yml" for the package names.

