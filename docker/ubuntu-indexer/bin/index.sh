#!/bin/bash
# downloads latest dxr.config from repo and indexes the given tree

# Grab the latest config
wget -q -O dxr.config https://github.com/mozilla-platform-ops/dxr-infra/raw/master/dxr.config

update_hg_repo() {
    local url=$1
    local repo=$2
    local root=$3
    if [ -d "${root}/${repo}/.hg" ]; then
        echo "Updating ${root}/$repo..."
        (cd ${root}/${repo} && hg pull -u)
    else
        echo "Cloning $url/$repo to ${root}/${repo}"
        hg clone ${url}/${repo} ${root}/${repo}
    fi
}

# handle cloning/updating repo "collections" to workaround jenkins MultiSCM issue
# build-central and nss are special cases; either mixed VCS or partial subdirs
# only hg.mozilla.org repo "collections" are handled currently
if [ 'build-central' == "$1" ]; then
    for i in $(ls -d src/build/*); do
        (cd $i; hg pull -u || git pull)
    done
elif [ 'nss' == "$1" ]; then
    for i in $(ls -d src/nss/*); do
        (cd $i && hg pull -u)
    done
elif [[ -v TREE_URL && -v TREE_ROOT ]]; then
    repolist=( $(curl -s -f $TREE_URL | gawk -F\" 'match($0, /class="list" href="[^"]*\/([^"\/]+)\/"/, arr) {print arr[1]}') )
    for repo in "${repolist[@]}"; do
        update_hg_repo $TREE_URL $repo src/$TREE_ROOT
    done
fi

exec venv/bin/dxr index -c dxr.config -v "$1"
