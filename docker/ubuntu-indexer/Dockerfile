# https://github.com/docker-library/docs/blob/master/ubuntu/tag-details.md
FROM library/ubuntu@sha256:b2c8a4d46473ab082200880391ddf8c06f2a67da4fa905ce2747dcd95d8d7af7
#FROM library/ubuntu@sha256:7ce82491d6e35d3aa7458a56e470a821baecee651fba76957111402591d20fc1
MAINTAINER Kendall Libby <klibby@mozilla.com>

# Declare default working folder (override ubuntu-build)
WORKDIR     /home/jenkins

# Cache buster
ADD https://api.github.com/repos/mozilla/dxr/git/refs/heads/ci /home/jenkins/dxr-version

# Install system dependencies in a single layer
ADD         bin                 /home/jenkins/bin
RUN         ["/home/jenkins/bin/system-setup.sh"]

# So that the compilers can find necessary libraries
# gcc
ENV         LIBRARY_PATH        /usr/lib/x86_64-linux-gnu
ENV         PATH                /home/jenkins/bin:/home/jenkins/venv/bin:/usr/lib/llvm-3.6/bin:$PATH

# Install DXR in a single layer
RUN         ["/home/jenkins/bin/dxr-setup.sh"]

# Set variable normally configured at login, by the shells parent process, these
# are taken from GNU su manual
ENV         HOME        /home/jenkins
ENV         SHELL       /bin/bash
ENV         USER        jenkins
ENV         LOGNAME     jenkins

# Set a default command useful for debugging
CMD ["/bin/bash", "--login"]
