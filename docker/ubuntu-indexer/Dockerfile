# https://github.com/docker-library/docs/blob/master/ubuntu/tag-details.md
FROM library/ubuntu@sha256:7ce82491d6e35d3aa7458a56e470a821baecee651fba76957111402591d20fc1
MAINTAINER Kendall Libby <klibby@mozilla.com>

# Declare default working folder (override ubuntu-build)
WORKDIR     /builds/dxr-build-env

# Cache buster
ADD https://api.github.com/repos/mozilla/dxr/git/refs/heads/ci /builds/dxr-build-env/dxr-version

# Install system dependencies in a single layer
ADD         bin                 /builds/dxr-build-env/bin
RUN         ["/builds/dxr-build-env/bin/system-setup.sh"]

# So that the compilers can find necessary libraries
# gcc
ENV         LIBRARY_PATH        /usr/lib/x86_64-linux-gnu
ENV         PATH                /builds/dxr-build-env/bin:/builds/dxr-build-env/venv/bin:/usr/lib/llvm-3.7/bin:$PATH

# Install DXR in a single layer
RUN         ["/builds/dxr-build-env/bin/dxr-setup.sh"]

# Set variable normally configured at login, by the shells parent process, these
# are taken from GNU su manual
ENV         HOME        /home/jenkins
ENV         SHELL       /bin/bash
ENV         USER        jenkins
ENV         LOGNAME     jenkins

# Set a default command useful for debugging
CMD ["/bin/bash", "--login"]
