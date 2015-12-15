# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

from __future__ import absolute_import, unicode_literals

import json
import logging
import os
from pipes import quote
import subprocess

HERE = os.path.abspath(os.path.dirname(__file__))
ROOT = os.path.join(HERE, '..')
ANSIBLE = os.path.join(ROOT, 'ansible')
DOCKER = os.path.join(ROOT, 'docker')

logger = logging.getLogger(__name__)


def run_playbook(name, limit_vars=None, extra_vars=None, verbosity=0):
    limit_vars = limit_vars or {}
    extra_vars = extra_vars or {}

    args = [
        'ansible-playbook',
        '-i', os.path.join(ANSIBLE, 'hosts'),
        '-f', '20',
        '%s.yml' % name,
    ]
    if limit_vars:
        args.extend(['-l', limit_vars])
    if extra_vars:
        args.extend(['--extra-vars', json.dumps(extra_vars)])
    if verbosity:
        args.append('-%s' % ('v' * verbosity))

    logger.info('$ %s' % ' '.join([quote(a) for a in args]))
    return subprocess.call(args, cwd=ANSIBLE)


def deploy_dxrmo(verbosity=0):
    """Deploy to dxr.mozilla.org."""
    return run_playbook('deploy-dxrmo', verbosity=verbosity)


def deploy_update_config(verbosity=0):
    """Generate DXR and jenkins-job-builder config files."""
    import update_config
    update_config.main()


def deploy_restart_builder(node, verbosity=0):
    """Restart docker on a builder node."""
    limit = node
    return run_playbook('restart-builder', limit_vars=limit,
                        verbosity=verbosity)


def deploy_trigger_build(jobs, verbosity=0):
    """Schedule indexing jobs on Jenkins."""
    extra = {'jobs': jobs}
    # return run_playbook('trigger-jobs', extra_vars=extra,
    #                     verbosity=verbosity)
    print "trigger jobs: {0}".format(extra['jobs'])


def deploy_trigger_all(verbosity=0):
    """Schedule all Jenkins jobs to run."""
    # return run_playbook('trigger-all-jobs', verbosity=verbosity)
    print "trigger all!"
