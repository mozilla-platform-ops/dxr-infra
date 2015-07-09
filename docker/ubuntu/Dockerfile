FROM quay.io/djmitche/ubuntu-build:0.0.2
MAINTAINER Kendall Libby <klibby@mozilla.com>

# Declare default working folder
WORKDIR     /builds/dxr-build-env
#
# Ensure that DXR specific dependencies live in a single layer
ADD           dxr-setup.sh   /tmp/dxr-setup.sh
RUN           ["/tmp/dxr-setup.sh"]

ENV PATH /usr/lib64/ccache:$PATH

# Set a default command useful for debugging
CMD ["/bin/bash", "--login"]
