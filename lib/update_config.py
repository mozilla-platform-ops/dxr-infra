#!/usr/bin/env python2.7
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.

import os
import re
import sys
import urlparse
import tempfile
import yaml

from jinja2 import Environment, FileSystemLoader

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, '..')
TEMPLATE_DIR = os.path.join(ROOT, 'templates')
config_file = os.path.join(ROOT, 'config.yml')

TEMPLATES = {
    'dxr_config.j2': os.path.join(ROOT, 'dxr.config'),
    'jobs.yml.j2': os.path.join(ROOT, 'jobs.yml'),
}

SCM_HOSTS = {
    'hg.mozilla.org': 'hg',
    'git.mozilla.org': 'git',
    'github.com': 'git',
}


def cleanup_url(url):
    git_re = re.compile('\.git$')
    wildcard_re = re.compile('/\*$')
    if git_re.search(url):
        url = url[:-4]
    elif wildcard_re.search(url):
        url = url[:-1]
    return url


def normalize_repo_vars(repo, repo_dir):
    repo['url'] = cleanup_url(repo['url'])
    u = urlparse.urlsplit(repo['url'])

    if 'type' not in repo:
        try:
            repo['type'] = SCM_HOSTS[u.netloc]
        except KeyError:
            print 'Unknown host/SCM type'
            raise

    if 'dirname' not in repo:
        repo['dirname'] = u.path.strip('/').split('/')[-1]

    if 'name' not in repo:
        repo['name'] = "{0}-{1}".format(repo['type'], repo['dirname'])

    if repo['type'] is 'hg':
        if 'revision' not in repo:
            repo['revision'] = 'default'
        if 'revision_type' not in repo:
            repo['revision_type'] = 'branch'
        repo['subdir'] = os.path.join(repo_dir, repo['dirname'])

    if repo['type'] is 'git':
        repo['basedir'] = os.path.join(repo_dir, repo['dirname'])

    return(repo)


def envget(dict, key):
    try:
        return os.environ['DXR_' + key.upper()]
    except KeyError:
        return dict[key]


def read_config(file):
    try:
        f = open(file, 'r')
        config = yaml.safe_load(f)
    except IOError as e:
        print "I/O error({0}): {1}".format(e.errno, e.strerror)
    finally:
        f.close()
    return(config)


def write_config_files(trees, dxr_config):
    template_env = Environment(
        loader=FileSystemLoader(TEMPLATE_DIR),
        keep_trailing_newline=True,
        lstrip_blocks=True,
        trim_blocks=False,
    )

    for t in TEMPLATES:
        print "Writing {0}".format(os.path.basename(TEMPLATES[t]))
        with tempfile.NamedTemporaryFile('w', dir=ROOT, delete=False) as tf:
            tf.write(template_env.get_template(t).render(trees=trees,
                                                         dxr=dxr_config))
            tempname = tf.name
        os.rename(tempname, TEMPLATES[t])


def check_tree_name(tree):
    name_re = re.compile('[/:]')
    if name_re.search(tree['name']) is not None:
        raise Exception("Invalid characters ('/:') in name.", tree['name'])


def main():
    cfg = read_config(config_file)

    # override defaults with ENV
    dxr_config = cfg['dxr']
    for i in dxr_config:
        dxr_config[i] = envget(dxr_config, i)

    trees = []
    for t in cfg['trees']:
        check_tree_name(t)

        if 'plugins' not in t:
            t['plugins'] = []

        if 'proj_dir' not in t:
            if len(t['repos']) > 1:
                raise Exception("proj_dir must be set if using multiple repos",
                                t)
            else:
                t['path'] = cfg['defaults']['repo_dir']
        else:
            t['path'] = os.path.join(cfg['defaults']['repo_dir'],
                                     t['proj_dir'])

        for r in t['repos']:
            if 'url' not in r:
                raise Exception("Missing or malformed repo URL entry.", r)
            r = normalize_repo_vars(r, t['path'])

        # awful hack because dirname isn't available before
        # normalize_repo_vars()
        if len(t['repos']) == 1:
            if 'proj_dir' not in t:
                t['proj_dir'] = t['repos'][0]['dirname']
            else:
                t['proj_dir'] = os.path.join(t['proj_dir'],
                                             t['repos'][0]['dirname'])

        # obj_folder deprecated? bug 842547
        t['object_folder'] = os.path.join('obj', t['proj_dir'])
        t['source_folder'] = os.path.join('src', t['proj_dir'])
        # merge default plugin conf with this one
        plugin_keys = [conf['plugin'] for conf in t['plugins']]
        t['plugins'].extend([conf for conf in cfg['defaults']['dxr_plugins']
                             if conf['plugin'] not in plugin_keys])

        # merge dicts, with tree dict taking precedence
        trees.append(dict(cfg['defaults'], **t))

    write_config_files(trees, dxr_config)

if __name__ == '__main__':
    sys.exit(main())
