#!/bin/bash -ve

### Check that we are running as root
test `whoami` == 'root';

# ENV DXR_HOME /builds/dxr-build-env
# ENV LD_LIBRARY_PATH /tools/gcc-4.3.3/installed/lib64:$DXR_HOME/dxr/trilite
# ENV PATH /usr/lib64/ccache:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/tools/git/bin:$DXR_HOME/clang/bin

### Add jenkins user
useradd -u 5507 -d /home/jenkins -s /bin/bash -m jenkins;


mkdir -p /builds/dxr-build-env/src
chown -R jenkins:jenkins /builds

# Make mach happy
mkdir /home/jenkins/.mozbuild && chown jenkins:jenkins /home/jenkins/.mozbuild
cat <<EOM > /home/jenkins/.hgrc
[ui]
username = jenkins <jenkins@nowhere>
[diff]
git = 1
showfunc = 1
unified = 8
EOM
chown jenkins:jenkins /home/jenkins/.hgrc

mkdir -p /etc/mercurial
cat <<EOF > /etc/mercurial/hgrc
[trusted]
users = root, jenkins

[web]
cacerts = /etc/pki/tls/certs/ca-bundle.crt
EOF

cd /builds/dxr-build-env

# Hack to install a useful, if old, version of Clang
curl -L https://s3-us-west-2.amazonaws.com/moz-dxr/clang-3.3.tar.bz2 | tar -xj

# Install DXR
REV=$(curl -s https://ci.mozilla.org/job/dxr/lastSuccessfulBuild/git/api/json | jq -r '.buildsByBranchName["refs/remotes/origin/master"].revision.SHA1')
if [[ ${REV} =~ ^[![:xdigit:]{32,40}]$ ]]; then
    echo "bad dxr rev $REV"
    exit 1
fi
git clone --recursive https://github.com/mozilla/dxr && \
    (cd dxr && git checkout $REV)

/bin/env CC=clang CXX=clang++ make -C dxr

virtualenv-2.7 venv
. venv/bin/activate
pip install -r dxr/requirements.txt && \
    cd dxr && \
    python setup.py install && \
    cd - && \
    deactivate

# Remove this script
rm $0; echo "Deleted $0";
