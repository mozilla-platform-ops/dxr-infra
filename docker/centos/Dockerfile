FROM            centos:centos6
MAINTAINER      Kendall Libby <klibby@mozilla.com>

# Install system dependencies in a single layer
ADD         system-setup.sh     /tmp/system-setup.sh
RUN         ["/tmp/system-setup.sh"]

# Install DXR in a single layer
ADD         dxr-setup.sh        /tmp/dxr-setup.sh
RUN         ["/tmp/dxr-setup.sh"]

# Set variable normally configured at login, by the shells parent process, these
# are taken from GNU su manual
ENV         HOME        /home/worker
ENV         SHELL       /bin/bash
ENV         USER        worker
ENV         LOGNAME     worker
ENV         PATH        /builds/dxr-build-env/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Declare default working folder
WORKDIR     /builds/dxr-build-env

# Set a default command useful for debugging
CMD ["/bin/bash", "--login"]
