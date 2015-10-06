#!/bin/bash -ve

### Check that we are running as root
test `whoami` == 'root';

### Add jenkins user
useradd -u 5507 -d /home/jenkins -s /bin/bash -m jenkins;

mkdir -p /builds/dxr-build-env/src
chown -R jenkins:jenkins /builds

# Configure mercurial
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

# Get current blessed rev
REV=$(curl -s https://ci.mozilla.org/job/dxr/lastSuccessfulBuild/git/api/json | jq -r '.buildsByBranchName["refs/remotes/origin/master"].revision.SHA1')
if [[ ${REV} =~ ^[![:xdigit:]{32,40}]$ ]]; then
    echo "bad dxr rev $REV"
    exit 1
fi
git clone --recursive https://github.com/mozilla/dxr && \
    (cd dxr && git checkout $REV)

env CC=clang CXX=clang++ make -C dxr

#curl -L https://bitbucket.org/pypy/pypy/downloads/pypy-2.6.0-linux64.tar.bz2 | tar -xj
#virtualenv -p pypy-2.6.0-linux64/bin/pypy venv
virtualenv venv
. venv/bin/activate
dxr/peep.py install -r dxr/requirements.txt && \
    cd dxr && \
    python setup.py install && \
    cd - && \
    deactivate

# Remove this script
rm $0; echo "Deleted $0";
