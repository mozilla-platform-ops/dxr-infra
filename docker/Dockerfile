FROM mrrrgn/releng_base_linux_64_builds
MAINTAINER Kendall Libby <klibby@mozilla.com>

COPY mrepo.repo /etc/yum.repos.d/mrepo.repo
RUN yum install -y \
    libxml2-devel \
    libxslt-devel \
    mercurial \
    nodejs \
    npm \
    python27-devel \
    python27-pip \
    python27-virtualenv \
    pyxdg \
    vi

ENV SHELL /bin/bash
ENV DXR_HOME /builds/dxr-build-env
ENV LC_ALL C
ENV LD_LIBRARY_PATH /tools/gcc-4.3.3/installed/lib64:$DXR_HOME/dxr/trilite
ENV PATH /usr/lib64/ccache:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/tools/git/bin:$DXR_HOME/clang/bin

RUN mkdir -p $DXR_HOME/src
WORKDIR $DXR_HOME
ADD clang-3.3.tar.bz2 $DXR_HOME/
RUN git clone --recursive -b $DXR_BRANCH $DXR_REPO && cd dxr && git co $DXR_REV
RUN /bin/env CC=clang CXX=clang++ make

WORKDIR $DXR_HOME
RUN virtualenv-2.7 venv && venv/bin/pip install -r dxr/requirements.txt && cd dxr && ../venv/bin/python setup.py install

COPY ../dxr.config $DXR_HOME/dxr.config
