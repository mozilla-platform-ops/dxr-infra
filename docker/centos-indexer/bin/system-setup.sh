#!/bin/bash -ve

### Check that we are running as root
test `whoami` == 'root';

# Install IUS repo for packages from this decade
yum install -y https://centos6.iuscommunity.org/ius-release.rpm
rpm --import /etc/pki/rpm-gpg/IUS-COMMUNITY-GPG-KEY

yum_packages=()

# Dependencies for setup
yum_packages+=('wget')
yum_packages+=('python27-devel')
yum_packages+=('python27-pip')
yum_packages+=('python27-virtualenv')
yum_packages+=('python27-backports')
yum_packages+=('curl')
yum_packages+=('git2u')
yum_packages+=('jq')

# Dependencies for DXR
yum_packages+=('clang')
yum_packages+=('clang-devel')
yum_packages+=('llvm')
yum_packages+=('llvm-devel')
yum_packages+=('npm')
yum_packages+=('nodejs')
yum_packages+=('nodejs-devel')

# Dependencies for rust
yum_packages+=('ccache')
yum_packages+=('gperf')

# Dependencies for NSS/NSPR
yum_packages+=('zlib-devel')

yum update -y
yum install -y ${yum_packages[@]}

# Sadly not available via EPEL or IUS
wget -O /tmp/mercurial.rpm https://www.mercurial-scm.org/release/centos6/RPMS/x86_64/mercurial-3.6.1-1.x86_64.rpm
yum install -y /tmp/mercurial.rpm
rm -f /tmp/mercurial.rpm

# Install deps for mozilla-central
wget -O bootstrap.py https://hg.mozilla.org/mozilla-central/raw-file/tip/python/mozboot/bin/bootstrap.py
python2.7 bootstrap.py --application-choice=desktop --no-interactive
rm -f bootstrap.py

# Install bundleclone extension
mkdir /builds/dxr-build-env/hgext
wget -O /builds/dxr-build-env/hgext/bundleclone.py \
        https://hg.mozilla.org/hgcustom/version-control-tools/raw-file/default/hgext/bundleclone/__init__.py

mkdir -p /etc/mercurial
cat <<EOF > /etc/mercurial/hgrc
[trusted]
users = root, jenkins

[web]
cacerts = /etc/ssl/certs/ca-bundle.crt

[extensions]
bundleclone  = /builds/dxr-build-env/hgext/bundleclone.py
#prefers = ec2region=us-west-2, stream=revlogv1
EOF

# Awful hack for GTK3 on Centos6; this is why we should be emulating Releng builds
curl -L http://tooltool.pvt.build.mozilla.org/build/sha512/68fc56b0fb0cdba629b95683d6649ff76b00dccf97af90960c3d7716f6108b2162ffd5ffcd5c3a60a21b28674df688fe4dabc67345e2da35ec5abeae3d48c8e3 | tar -xJ

### Clean up from setup
yum clean all

# Remove the setup.sh setup, we don't really need this script anymore, deleting
# it keeps the image as clean as possible.
rm $0; echo "Deleted $0";

