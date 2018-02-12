#!/bin/bash

set -ve

### Check that we are running as root
test `whoami` == 'root';

apt_packages=()

# Dependencies for setup
apt_packages+=('software-properties-common')
apt_packages+=('wget')
apt_packages+=('lsb-release')
apt_packages+=('python2.7-dev')
apt_packages+=('python-pip')
apt_packages+=('python-virtualenv')
apt_packages+=('pypy')
apt_packages+=('curl')
apt_packages+=('git')
apt_packages+=('jq')
apt_packages+=('gawk')
apt_packages+=('sudo')

# Dependencies for debugging
apt_packages+=('vim')
apt_packages+=('strace')

# Dependencies for DXR
apt_packages+=('clang-3.9')
apt_packages+=('libclang-3.9-dev')
apt_packages+=('llvm-3.9')
apt_packages+=('llvm-3.9-dev')
apt_packages+=('npm')

# Dependency for nodejs
apt_packages+=('apt-transport-https')

# Dependencies for rust
apt_packages+=('ccache')
apt_packages+=('gperf')

# Dependencies for NSS/NSPR
apt_packages+=('gcc-multilib')
apt_packages+=('zlib1g-dev')
apt_packages+=('lib32z1-dev')

# Missing dependenciess for m-c/c-c ?
apt_packages+=('libnspr4')
apt_packages+=('gstreamer0.10')
apt_packages+=('gstreamer0.10-plugins-base')
apt_packages+=('libgstreamer-plugins-base0.10-dev')
apt_packages+=('libgl1-mesa-dev')
apt_packages+=('libgl1-mesa-glx')

apt-get update -y

apt-get install -y --force-yes ${apt_packages[@]}
apt-get build-dep -y clang-3.9 llvm-3.9
apt-get autoremove

# Workaround for llvm-config not existing in non-default versions
update-alternatives --force --install /usr/local/bin/llvm-config llvm-config /usr/bin/llvm-config-3.9 0

# Ubuntu lags well behind on mercurial updates
add-apt-repository ppa:mercurial-ppa/releases
apt-get update -y
apt-get install -y --force-yes mercurial mercurial-common

# Add a newer version of node that supports ES6.
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
DISTRO=$(lsb_release -c -s)
echo "deb https://deb.nodesource.com/node_6.x ${DISTRO} main" > /etc/apt/sources.list.d/nodesource.list
echo "deb-src https://deb.nodesource.com/node_6.x ${DISTRO} main" >> /etc/apt/sources.list.d/nodesource.list
apt-get update -y
apt-get install -y nodejs

# Install deps for mozilla-central
wget -O bootstrap.py https://hg.mozilla.org/mozilla-central/raw-file/tip/python/mozboot/bin/bootstrap.py
python2.7 bootstrap.py --application-choice=browser --no-interactive
rm -f bootstrap.py

# Dependencies for rust crates
NO_PROXY="sh.rustup.rs" wget -O rustup.sh https://sh.rustup.rs
bash rustup.sh -y --default-toolchain nightly
rm -f rustup.sh

mkdir -p /etc/mercurial
cat <<EOF > /etc/mercurial/hgrc
[trusted]
users = root, jenkins

[web]
cacerts = /etc/ssl/certs/ca-certificates.crt

[extensions]
clonebundles = 
#prefers = ec2region=us-west-2, stream=revlogv1
EOF

rm $0; echo "Deleted $0";
