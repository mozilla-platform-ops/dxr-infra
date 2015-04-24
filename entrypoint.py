#!/usr/bin/env python
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.

import os
import re
import subprocess
import sys
import urlparse
import yaml

from jinja2 import Environment, FileSystemLoader

dxr_home = os.environ['DXR_HOME']
cfg_dir = dxr_home
config = os.path.join(cfg_dir, 'entrypoint-config.yml')


class Unbuffered(object):

    # Dirty hack to make stdout unbuffered. This matters for Docker log viewing.

    def __init__(self, s):
        self.s = s

    def write(self, d):
        self.s.write(d)
        self.s.flush()

    def __getattr__(self, a):
        return getattr(self.s, a)

sys.stdout = Unbuffered(sys.stdout)

# We also assign stderr to stdout because Docker sometimes doesn't capture
# stderr by default.
sys.stderr = sys.stdout


class SetupRepo(object):

    def __init__(self, url):
        self.fullurl = url
        self.url = urlparse.urlsplit(self.fullurl)
        self.path = self.url.path.lstrip('/')
        self.hg_or_git(url)
        self.load_config(config, self.fullurl)
        self.config['path'] = self.path
        self.config['source_dest'] = os.path.join('src', self.path)
        self.config['source_parent'] = os.path.dirname(
            self.config['source_dest'])
        self.config['object_dir'] = os.path.join('obj', self.path)
        self.template_env = Environment(
            loader=FileSystemLoader(os.path.join(cfg_dir, 'templates')),
            keep_trailing_newline=True,
        )
        self.templates = {
            'dxr_config.j2': os.path.join(dxr_home, 'dxr.config'),
            'mozconfig.j2': os.path.join(self.config['source_dest'],
                                         '.mozconfig'),
        }

    def load_config(self, config_file, repo_path):
        f = open(config_file, 'r')
        cfg = yaml.safe_load(f)
        try:
            self.config = cfg[repo_path]
        except KeyError:
            self.config = cfg['default']
        f.close()

    def render_template(self, template):
        return self.template_env.get_template(template).render(self.config)

    def create_config_files(self):
        for t in self.templates:
            if t == 'mozconfig.j2' and not self.config['build_command']:
                continue
            else:
                fname = self.templates[t]
                with open(fname, 'a') as f:
                    contents = self.render_template(t)
                    f.write(contents)
                    f.close()
                # print contents
                # print "---"

    def hg_or_git(self, url):
        git_re = re.compile(r'git(hub\.com|\.mozilla\.(org|com))')
        hg_re = re.compile(r'hg\.mozilla\.org')
        if git_re.match(self.url.netloc):
            self.cmd = 'git'
            self.update_cmd = ['fetch', '-u']
        elif hg_re.match(self.url.netloc):
            self.cmd = 'hg'
            self.update_cmd = ['pull', '-u']
        else:
            print 'No match'

    def clone_or_update(self):
        if not os.path.exists(self.config['source_dest']):
            try:
                os.stat(self.config['source_parent'])
            except:
                os.makedirs(self.config['source_parent'], 0755)
            subprocess.check_call([self.cmd, 'clone', self.fullurl],
                                  cwd=self.config['source_parent'])
        else:
            subprocess.check_call([self.cmd] + self.update_cmd,
                                  cwd=self.config['source_dest'])


if __name__ == "__main__":
    for url in sys.argv[1:]:
        repo = SetupRepo(url)
        try:
            repo.clone_or_update()
            repo.create_config_files()
        except subprocess.CalledProcessError as e:
            print "Error: {0} returned {1}".format(e.cmd, e.output)
        except:
            print "Something went wrong!"
    sys.stdout.flush()
    os.execv('venv/bin/dxr',
             ['venv/bin/dxr', 'index', '-v', '--config dxr.config'])
