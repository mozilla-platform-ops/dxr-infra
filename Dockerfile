FROM mrrrgn/releng_base_linux_64_builds
MAINTAINER Kendall Libby <klibby@mozilla.com>

COPY mrepo.repo /etc/yum.repos.d/mrepo.repo
RUN yum install -y \
    mozilla-python27-virtualenv \
    pyxdg \
    python-devel \
    python-jinja2 \
    python-pygments \
    pip \
    sqlite-devel \
    npm \
    nodejs

RUN pip install \
    PyYAML \
    Jinja2==2.7.3

ENV SHELL /bin/bash
ENV DXR_BRANCH es
ENV DXR_REPO https://github.com/mozilla/dxr.git
ENV DXR_HOME /builds/dxr-build-env
ENV LC_ALL C
ENV LD_LIBRARY_PATH /tools/gcc-4.3.3/installed/lib64:$DXR_HOME/dxr/trilite
ENV PATH /tools/buildbot/bin:/usr/local/bin:/usr/lib64/ccache:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/tools/git/bin:/tools/python27/bin:/tools/python27-mercurial/bin:/home/cltbld/bin:$DXR_HOME/clang/bin

RUN mkdir $DXR_HOME
WORKDIR $DXR_HOME
ADD clang-3.3.tar.bz2 $DXR_HOME/
RUN git clone --recursive -b $DXR_BRANCH $DXR_REPO
COPY dxr.config $DXR_HOME/dxr.config
COPY entrypoint-config.yml $DXR_HOME/entrypoint-config.yml
COPY entrypoint.py /entrypoint.py
RUN mkdir templates src obj
COPY templates/* $DXR_HOME/templates/

RUN /bin/env CC=clang CXX=clang++ make -C dxr
RUN /usr/local/bin/virtualenv --system-site-packages venv && venv/bin/pip install -r dxr/requirements.txt && cd dxr && ../venv/bin/python setup.py install

ENTRYPOINT ["/entrypoint.py"]
