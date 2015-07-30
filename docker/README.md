# Docker images

We use [Docker](https://www.docker.com/) images as reusable containers to run indexing jobs. Their purpose is not to be a perfectly recreateable environment, but rather to be a tool that one can use to test new builds with a high confidence that it will then work in production.

The `build.sh` script is provided to as a wrapper around `docker build` with specific concerns for image verion and registry deployment. Because it is not easily possible to pass version information into a docker build, nor selectively cache steps in the Dockerfile, builds are done with `--no-cache`. 

Base images are taken from [mozilla-central's builds](https://hg.mozilla.org/mozilla-central/file/default/testing/docker), with the DXR app and dependencies installed atop them.

