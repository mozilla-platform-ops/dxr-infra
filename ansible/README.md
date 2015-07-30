# Configuration management
Management of the DXR infrastructure is done using [Ansible](https://github.com/ansible/ansible), and requires access to the Mozilla VPN and root or sudo access to the constituent hosts.

## Overview
(insert pretty picture here of the envinronment)

Node roles, and possibly host names, are defined in `dxr.yml`, along with role specific variables. Host groups and hostnames are defined in the `hosts` file.

Code deployment and updates to the webapp-accessible `dxr.config` are done on the admin node. It is also currently the Jenkins master node. 

Web nodes run apache and the WSGI app. The source code tree is available as a read-only NFS mount.

Builder nodes are Jenkins slaves and run the docker images to index trees. The source code tree is available as read-write NFS mount, and trees are updated by Jenkins.
