# Docker container for DXR indexing to Elasticsearch

[DXR](https://github.com/mozilla/dxr) is a code search and navigation tool aimed at making sense of large projects like Firefox.

This repo contains:
* Tools to manage dxr.mozilla.org, dxr.allizom.org, and the DXR build infrastructure
* Docker images for indexing trees

## Prerequisites and setup
- docker/boot2docker config change to increase disk space / image size
- local src tree
- credentials

## Usage

TODO: Write usage instructions
### Using the Docker images to test builds
- fork repo
- add tree to config.yml
-- restrictions: tree names can't contain "[:/]" due to Elasticsearch and jenkins-job-builder internals
- run create-config.py to generate new dxr.config and jobs.yml files
- build and run docker image
-- edit dxr.config in running image and add tree entry from above
-- change Elasticsearch settings to point at local instance
- index the new tree
- commit any changes and submit a PR

### Managing Docker images
- adding new images
- building new images
- publishing new/updated images

### Using Ansible to manage the infrastructure
- pushing new dxr.config to web heads

### Using jenkins-job-builder to manage Jenkins
- adding/updating Jenkins jobs
- removing jobs


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
