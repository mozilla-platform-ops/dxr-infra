#!/bin/bash -ve

### Check that we are running as root
test `whoami` == 'root';

### Add jenkins user
useradd -u 5507 -d /home/jenkins -s /bin/bash -m jenkins;

mkdir -p /builds/dxr-build-env/src
chown -R jenkins:jenkins /builds

# Install deps for DXR and rust
apt-get update -y
apt-get install -y      \
    clang               \
    libclang-dev        \
    llvm                \
    llvm-dev            \
    libxslt1-dev        \
    libyaml-dev         \
    libz-dev            \
    freeglut3-dev       \
    xorg-dev            \
    gperf               \
    cmake               \
    libssl-dev          \
    libbz2-dev          \
    libosmesa6-dev      \
    libxmu6             \
    libxmu-dev          \
    ;
apt-get build-dep -y clang llvm

# The system hg version will barf on this until Ubuntu updates to >= 3.4
mkdir /builds/dxr-build-env/hgext
wget -O /builds/dxr-build-env/hgext/bundleclone.py \
    https://hg.mozilla.org/hgcustom/version-control-tools/raw-file/default/hgext/bundleclone/__init__.py

# Configure mercurial
mkdir -p /etc/mercurial
cat <<EOF > /etc/mercurial/hgrc
[trusted]
users = root, jenkins

[web]
cacerts = /etc/ssl/certs/ca-certificates.crt

[extensions]
bundleclone  = /builds/dxr-build-env/hgext/bundleclone.py
#prefers = ec2region=us-west-2, stream=revlogv1
EOF

git clone --recursive -b es https://github.com/mozilla/dxr
env LD_LIBRARY_PATH=/builds/dxr-build-env/dxr/trilite \
    CC=clang    \
    CXX=clang++ \
    make -C dxr

curl -L https://bitbucket.org/pypy/pypy/downloads/pypy-2.6.0-linux64.tar.bz2 | tar -xj
virtualenv -p pypy-2.6.0-linux64/bin/pypy penv
. penv/bin/activate
dxr/peep.py install -r dxr/requirements.txt && \
    cd dxr && \
    python setup.py install && \
    cd -

# Grab the latest config
wget -O dxr.config https://github.com/klibby/dxr-docker/raw/rust/dxr.config

# Remove this script
rm $0; echo "Deleted $0";
