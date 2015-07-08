#!/bin/bash -ve

### Check that we are running as root
test `whoami` == 'root';

# ENV DXR_HOME /builds/dxr-build-env
# ENV LD_LIBRARY_PATH /tools/gcc-4.3.3/installed/lib64:$DXR_HOME/dxr/trilite
# ENV PATH /usr/lib64/ccache:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/tools/git/bin:$DXR_HOME/clang/bin

mkdir -p /builds/dxr-build-env/src
chown -R worker:worker /builds

mkdir -p /etc/mercurial
cat <<EOF > /etc/mercurial/hgrc
[trusted]
users = root, worker

[web]
cacerts = /etc/pki/tls/certs/ca-bundle.crt
EOF

cd /builds/dxr-build-env

# Hack to install a useful, if old, version of Clang
#curl -L https://s3-us-west-2.amazonaws.com/moz-dxr/clang-3.3.tar.bz2 | tar -xj

# Install DXR
git clone --recursive -b es https://github.com/mozilla/dxr

#/bin/env PATH=${PATH}:/builds/dxr-build-env/clang/bin \
/bin/env LD_LIBRARY_PATH=/builds/dxr-build-env/dxr/trilite
    CC=clang \
    CXX=clang++ \
    make -C dxr

virtualenv-2.7 venv
. venv/bin/activate
pip install -r dxr/requirements.txt && \
    cd dxr && \
    python setup.py install && \
    cd - && \
    deactivate

# Grab the latest config
wget -O dxr.config https://github.com/klibby/dxr-docker/raw/rust/dxr.config

# Remove this script
rm $0; echo "Deleted $0";
