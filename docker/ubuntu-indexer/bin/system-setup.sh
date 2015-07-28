#!/bin/bash -ve

### Check that we are running as root
test `whoami` == 'root';

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
    libgtk-3-dev        \
    ;
apt-get build-dep -y clang llvm

# Install bundleclone extension
mkdir /builds/dxr-build-env/hgext
wget -O /builds/dxr-build-env/hgext/bundleclone.py \
    https://hg.mozilla.org/hgcustom/version-control-tools/raw-file/default/hgext/bundleclone/__init__.py

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

rm $0; echo "Deleted $0";
