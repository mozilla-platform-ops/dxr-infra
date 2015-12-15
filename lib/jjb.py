# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

from __future__ import absolute_import, unicode_literals

import logging
import os
from pipes import quote
import subprocess

HERE = os.path.abspath(os.path.dirname(__file__))
ROOT = os.path.join(HERE, '..')
JJB = os.path.join(ROOT, 'jjb')
CREDS = os.path.join(ROOT, 'credentials')

logger = logging.getLogger(__name__)


def run_jjb(action, log_level, extra_vars=None):
    extra_vars = extra_vars or []
    defaults_file = os.path.join(JJB, 'defaults.yml')
    job_file = os.path.join(ROOT, 'jobs.yml')

    args = [
        'jenkins-jobs',
        '--conf', os.path.join(CREDS, 'jjb.ini'),
        '-l', log_level,
        '%s' % action,
        '%s:%s' % (defaults_file, job_file),
    ]
    if extra_vars:
        args.extend('%s' % e for e in extra_vars)

    logger.info('$ %s' % ' '.join([quote(a) for a in args]))
    return subprocess.call(args, cwd=ROOT)


def jjb_test_job_config(jobs, log_level):
    """Test Jenkins job configuration."""
    extra = jobs
    return run_jjb('test', log_level=log_level, extra_vars=extra)


def jjb_update_job_config(jobs, log_level):
    """Update Jenkins job configuration."""
    extra = jobs
    return run_jjb('update', log_level=log_level, extra_vars=extra)


def jjb_delete_job_config(jobs, log_level):
    """Delete Jenkins job configuration."""
    extra = jobs
    return run_jjb('delete', log_level=log_level, extra_vars=extra)
