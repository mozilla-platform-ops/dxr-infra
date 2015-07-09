#!/bin/bash -ve

### Check that we are running as root
test `whoami` == 'root';

### Add jenkins user
useradd -u 5507 -d /home/jenkins -s /bin/bash -m jenkins;

mkdir -p /builds/dxr-build-env/src
chown -R jenkins:jenkins /builds

mkdir -p /etc/mercurial
cat <<EOF > /etc/mercurial/hgrc
[trusted]
users = root, jenkins

[web]
cacerts = /etc/ssl/certs/ca-certificates.crt
EOF

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

git clone --recursive -b es https://github.com/mozilla/dxr
env LD_LIBRARY_PATH=/builds/dxr-build-env/dxr/trilite \
    CC=clang    \
    CXX=clang++ \
    make -C dxr

virtualenv venv 
. venv/bin/activate
venv/bin/pip install -r dxr/requirements.txt && \
    cd dxr && \
    ../venv/bin/python setup.py install && \
    cd -

# Grab the latest config
wget -O dxr.config https://github.com/klibby/dxr-docker/raw/rust/dxr.config

# Remove this script
rm $0; echo "Deleted $0";
