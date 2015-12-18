# DXR build system

[DXR](https://github.com/mozilla/dxr) is a code search and navigation tool aimed at making sense of large projects like Firefox.

This repo contains:

 - [Ansible](https://github.com/ansible/ansible) configuration to manage the DXR build and web app infrastructure
 - [Docker](https://www.docker.com/) configuration for images used to index trees
 - [Jenkins Job Builder](http://docs.openstack.org/infra/jenkins-job-builder/) templates and configuration
 - Tools to generate the running environment and configurations for the above

## Prerequisites and setup
- Docker-toolbox or equiv for testing and updating Docker images
- MoCo LDAP account and SSH access for deploys
- Jenkins credentials for managing jobs

## `deploy` Usage
The `deploy` script is the main entry point for updating configuration files, managing jobs, and deploying changes to the infrastructure.  

### Regenerate DXR and Jenkins jobs configs
Running `deploy update-config` will read in `config.yml` and output new versions of `dxr.config` and `jobs.xml`. 


### Deploy infrastructure changes
Running `deploy dxrmo` will run the `deploy-dxrmo.yml` Ansible playbook, which manages the web servers, Jenkins server, build nodes, and the admin node. It also updates the `dxr.config` file used by the webheads.

> Deploying requires a MoCo LDAP account and SSH access to the nodes.

### Managing Jenkins build jobs
The deploy script has four commands for managing build jobs:

 - `deploy test-job [job ...]` will check for errors and output the Jenkins job XML for the given jobs (or all jobs if none specified).
 - `deploy update-job [job ...]` will update the named jobs (or all if none specified) in Jenkins
 - `deploy trigger-job <job>` will schedule a build of the specified job
 - `deploy trigger-all-jobs` will schedule a build of all jobs
 - `deploy delete-job <job>` will remove the specified job from Jenkins (but will not remove an existing index on dxr.m.o)

> Managing Jenkins jobs requires a MoCo LDAP account, SSH access to the nodes, and Jenkins access.

### Managing Docker images

 - Building or updating and image: `cd docker && ./build <image>`
 - Publishing an image: `docker push $(cat REGISTRY)/<image>/$(cat <image>/VERSION)`

## Adding a new tree
**TODO: Review and update**

- fork repo
- add tree to `config.yml`
>restrictions: tree names can't contain "[:/]" due to Elasticsearch and jenkins-job-builder internals

- run `deploy update-config` to generate new `dxr.config` and `jobs.yml` files
- build and run docker image
- copy `dxr.config` into running image
- change Elasticsearch settings to point at local instance
- run `./bin/index.sh <tree>` in the running image to build the tree
- commit any changes and submit a PR



## Troubleshooting
TBD!

Feel free to ask for help in **#vcs** on irc.mozilla.org!



## License

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

