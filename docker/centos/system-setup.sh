#!/bin/bash -ve

################################### setup.sh ###################################

### Check that we are running as root
test `whoami` == 'root';

### Add worker user
# Minimize the number of things which the build script can do, security-wise
# it's not a problem to let the build script install things with yum. But it
# really shouldn't do this, so let's forbid root access.
useradd -u 5507 -d /home/worker -s /bin/bash -m worker;

# Install extra package mirror
yum install -y \
  epel-release                      \
  wget                              \
  ;

# Install IUS repo for packages from this decade
wget -O /tmp/ius-release.rpm http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/ius-release-1.0-14.ius.centos6.noarch.rpm
rpm -Uvh /tmp/ius-release.rpm
rm /tmp/ius-release.rpm

### Install Useful Packages
# First we update and upgrade to latest versions.
yum update -y

# Let's install some goodies, ca-certificates is needed for https with hg.
# sudo will be required anyway, but let's make it explicit. It nice to have
# sudo around. We'll also install nano, this is pure bloat I know, but it's
# useful a text editor.
yum install -y                      \
  ca-certificates                   \
  sudo                              \
  nano                              \
  tar                               \
  wget                              \
  ;

# Install software from this decade for DXR
yum install -y                      \
  python27                          \
  python27-virtualenv               \
  python27-pip                      \
  python27-devel                    \
  python27-backports-ssl_match_hostname \
  npm                               \
  clang                             \
  clang-devel                       \
  llvm                              \
  llvm-libs                         \
  llvm-devel                        \
  yum-plugin-replace                \
  ;


## Sadly not available via EPEL or IUS
#wget -O /tmp/mercurial.rpm http://mercurial.selenic.com/release/centos6/RPMS/x86_64/mercurial-3.4.1-0.x86_64.rpm
#rpm -Uvh /tmp/mercurial.rpm
#rm /tmp/mercurial.rpm

# Then let's install all firefox build dependencies, these are extracted from
# mozboot. See python/mozboot/bin/bootstrap.py in mozilla-central.
yum groupinstall -y                 \
  "Development Tools"               \
  "Development Libraries"           \
  "GNOME Software Development"

# Replace git with a recent version
yum replace -y git --replace-with git2u

### Clean up from setup
# Remove cached packages. Cached package takes up a lot of space and
# distributing them to workers is wasteful.
yum clean all

# Remove the setup.sh setup, we don't really need this script anymore, deleting
# it keeps the image as clean as possible.
rm $0; echo "Deleted $0";

