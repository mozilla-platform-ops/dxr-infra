#!/bin/bash -ve

################################### setup.sh ###################################

### Check that we are running as root
test `whoami` == 'root';

### Add jenkins user
useradd -u 5507 -d /home/jenkins -s /bin/bash -m jenkins;


cat <<EOM >/etc/yum.repos.d/mrepo.repo
[mrepo-epel-x86_64]
name=mrepo-epel-x86_64
baseurl=https://mrepo.mozilla.org/mrepo/6-x86_64/RPMS.epel

[mrepo-centos6-x86_64-base]
name=mrepo-centos6-x86_64-base
baseurl=https://mrepo.mozilla.org/mrepo/6-x86_64/RPMS.centos-base

[mrepo-centos6-x86_64-updates]
name=mrepo-centos6-x86_64-updates
baseurl=https://mrepo.mozilla.org/mrepo/6-x86_64/RPMS.centos-updates

[mrepo-centos6-x86_64-mozilla]
name=Mozilla Package Repo - $basearch
baseurl=https://mrepo.mozilla.org/mrepo/6-x86_64/RPMS.mozilla
EOM

# Install IUS repo for packages from this decade
#wget -O /tmp/ius-release.rpm http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/ius-release-1.0-14.ius.centos6.noarch.rpm
#rpm -Uvh /tmp/ius-release.rpm
#rm /tmp/ius-release.rpm
#cat /etc/yum.repos.d/*

### Install Useful Packages
# First we update and upgrade to latest versions.
#yum update -y

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
  ncurses-devel                     \
  yum-plugin-replace                \
  ;


# Sadly not available via EPEL or IUS
wget -O /tmp/mercurial.rpm http://mercurial.selenic.com/release/centos6/RPMS/x86_64/mercurial-3.4.1-0.x86_64.rpm
rpm -Uvh /tmp/mercurial.rpm
rm /tmp/mercurial.rpm

# Then let's install all firefox build dependencies, these are extracted from
# mozboot. See python/mozboot/bin/bootstrap.py in mozilla-central.
yum install -y                      \
  autoconf213                       \
  curl-devel                        \
  alsa-lib-devel                    \
  dbus-glib-devel                   \
  GConf2-devel                      \
  glibc-static                      \
  gstreamer-devel                   \
  gstreamer-plugins-base-devel      \
  gtk2-devel                        \
  libstdc++-static                  \
  libXt-devel                       \
  mesa-libGL-devel                  \
  pulseaudio-libs-devel             \
  wireless-tools-devel              \
  yasm                              \
  which                             \
  ;

yum groupinstall -y                 \
  "Development Tools"               \
  "Development Libraries"           \
  "GNOME Software Development"      \
  ;

# Replace git with a recent version
#yum replace -y git --replace-with git2u

### Clean up from setup
# Remove cached packages. Cached package takes up a lot of space and
# distributing them to workers is wasteful.
yum clean all

# Remove the setup.sh setup, we don't really need this script anymore, deleting
# it keeps the image as clean as possible.
rm $0; echo "Deleted $0";

