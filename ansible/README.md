# Configuration management
Management of the DXR infrastructure is done using [Ansible](https://github.com/ansible/ansible), and requires access to the Mozilla VPN and root or sudo access to the constituent hosts.

## Secrets
Secrets used during deployment are stored in a separate repo with ansible-vault. The password to access the vault may be found in the RelOps gpg repo, in dxr-vault.gpg.

To use, check out the vault repo in the same directory as the dxr-infra repo. 
```
$ git clone https://github.com/mozilla-platform-ops/dxr-infra.git
$ git clone ssh://gitolite3@git-internal.mozilla.org/relops/dxr-vault.git
$ cd dxr-infra
$ ./deploy dxrmo
Vault password:
what is your MoCo email address?:
...
```

Running playbooks by hand will require adding the --ask-vault-pass option.
```
$ ansible-playbook -i hosts -l dxr-jenkins1* --ask-vault-pass deploy-dxrmo.yml
Vault password:
what is your MoCo email address?:
...
```

## Overview
(insert pretty picture here of the envinronment)

Node roles, and possibly host names, are defined in `dxr.yml`, along with role specific variables. Host groups and hostnames are defined in the `hosts` file.

Code deployment and updates to the webapp-accessible `dxr.config` are done on the admin node. It is also currently the Jenkins master node. 

Web nodes run apache and the WSGI app. The source code tree is available as a read-only NFS mount.

Builder nodes are Jenkins slaves and run the docker images to index trees. The source code tree is available as read-write NFS mount, and trees are updated by Jenkins.
