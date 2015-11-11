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
config_file = os.path.join(HERE, 'config.yml')


scm_hosts = {
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
            repo['type'] = scm_hosts[u.netloc]
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


if __name__ == '__main__':
    if 'VIRTUAL_ENV' not in os.environ:
        activate = os.path.join(HERE, 'venv', 'bin', 'activate_this.py')
        execfile(activate, dict(__file__=activate))
        sys.executable = os.path.join(HERE, 'venv', 'bin', 'python2.7')
        os.environ['VIRTUAL_ENV'] = os.path.join(HERE, 'venv')

    template_env = Environment(
        loader=FileSystemLoader(os.path.join(HERE, 'templates')),
        keep_trailing_newline=True,
        lstrip_blocks=True,
        trim_blocks=False,
    )
    templates = {
        'dxr_config.j2': os.path.join(HERE, 'dxr.config'),
        'jobs.yml.j2': os.path.join(HERE, 'jobs.yml'),
    }

    try:
        f = open(config_file, 'r')
        cfg = yaml.safe_load(f)
    except IOError as e:
        print "I/O error({0}): {1}".format(e.errno, e.strerror)
    finally:
        f.close()

    # override defaults with ENV
    dxr_config = cfg['dxr']
    for i in dxr_config:
        dxr_config[i] = envget(dxr_config, i)

    name_re = re.compile('[/:]')
    trees = []
    for t in cfg['trees']:
        if name_re.search(t['name']) is not None:
            raise Exception("Invalid characters ('/:') in name.", t['name'])

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

        # merge dicts, with tree dict taking precedence
        trees.append(dict(cfg['defaults'], **t))

    for t in templates:
        with tempfile.NamedTemporaryFile('w',
                                         dir=os.path.dirname(templates[t]),
                                         delete=False) as tf:
            tf.write(template_env.get_template(t).render(trees=trees,
                                                         dxr=dxr_config))
            tempname = tf.name
        os.rename(tempname, templates[t])
