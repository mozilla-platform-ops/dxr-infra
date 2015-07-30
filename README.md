# DXR build system

[DXR](https://github.com/mozilla/dxr) is a code search and navigation tool aimed at making sense of large projects like Firefox.

This repo contains:

 - [Ansible](https://github.com/ansible/ansible) configuration to manage the DXR build and web app infrastructure
 - [Docker](https://www.docker.com/) configuration for images used to index trees
 - [Jenkins Job Builder](http://docs.openstack.org/infra/jenkins-job-builder/) templates and configuration
 - Tools to generate the running environment and configurations for the above

## Prerequisites and setup
- docker/boot2docker config change to increase disk space / image size - TBD if still required
- credentials for JJB and docker

## Usage

### Using the Docker images to test builds
**TODO: Review and update**

- fork repo
- add tree to config.yml
    - restrictions: tree names can't contain "[:/]" due to Elasticsearch and jenkins-job-builder internals
- run `create-config.py` to generate new `dxr.config` and `jobs.yml` files
- build and run docker image
-- edit `dxr.config` in running image and add tree entry from above
-- change Elasticsearch settings to point at local instance
- index the new tree
- commit any changes and submit a PR

### Managing Docker images

 - Add a new image: TBA
 - Building or updating and image: `cd docker && ./build <image>`
 - Publishing an image: `docker push $(cat REGISTRY)/<image>/$(cat <image>/VERSION)`

### Using Ansible to manage the infrastructure
- Update `dxr.config` on production and staging web heads: `cd ansible && ansible-playbook dxr.yml -i hosts -l dxradm*`

### Using jenkins-job-builder to manage Jenkins

 - Run jenkins-job in test mode to verify output, supplying the tree to test:
`jenkins-jobs --conf credentials/jjb.ini test jjb/defaults.yml:jjb/jobs.yml newtree_index`


 - Update Jenkins with the new job: `jenkins-jobs --conf credentials/jjb.ini update jjb/defaults.yml:jjb/jobs.yml newtree_index`

 - Update all jobs: `jenkins-jobs --conf credentials/jjb.ini update jjb/defaults.yml:jjb/jobs.yml`

 - Delete a Jenkins job: `jenkins-jobs --conf credentials/jjb.ini delete jjb/defaults.yml:jjb/jobs.yml newtree_index`



## Troubleshooting

TODO: 

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## License

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

