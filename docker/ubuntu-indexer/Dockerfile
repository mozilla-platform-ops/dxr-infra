FROM quay.io/djmitche/ubuntu-build:0.0.2
MAINTAINER Kendall Libby <klibby@mozilla.com>

# Declare default working folder (override ubuntu-build)
WORKDIR     /builds/dxr-build-env

# Install system dependencies in a single layer
ADD         bin                 /builds/dxr-build-env/bin
RUN         ["/builds/dxr-build-env/bin/system-setup.sh"]

# So that the compilers can find necessary libraries
# # gcc
ENV         LIBRARY_PATH  /usr/lib/x86_64-linux-gnu
# # clang
ENV         CPLUS_INCLUDE_PATH /usr/include/c++/4.8:/usr/include/c++/4.8/backward:/usr/include/x86_64-linux-gnu/c++/4.8

ENV         PATH                /builds/dxr-build-env/bin:/builds/dxr-build-env/venv/bin:/tools/gcc-4.7.3-0moz1/bin:/usr/lib64/ccache:$PATH
ENV         LD_LIBRARY_PATH     /builds/dxr-build-env/dxr/trilite:/tools/gcc-4.7.3-0moz1/lib64:$LD_LIBRARY_PATH

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
