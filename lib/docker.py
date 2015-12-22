# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

from __future__ import absolute_import, unicode_literals

import json
import logging
import os
# from pipes import quote
import requests
# import subprocess

HERE = os.path.abspath(os.path.dirname(__file__))
ROOT = os.path.join(HERE, '..')
CREDS = os.path.join(ROOT, 'credentials')

logger = logging.getLogger(__name__)
payload = {"commit": "", "ref": "", "default_branch": "master"}


def get_latest_sha(gh_repo, ref):
    """Get the latest SHA from a GitHub repo on a given branch."""
    r = requests.get(gh_repo + ref, verify=True)
    try:
        r.raise_for_status()
    except requests.exceptions.HTTPError as e:
        print "HTTP Error:", e.message
        raise
    return str(r.json()['object']['sha'])[0:7]


def load_quay_settings(file):
    """Read quay.io trigger settings from a file."""
    with open(file, 'rb') as fh:
        return json.load(fh)


def trigger_quay_build(url, payload):
    """Trigger a quay.io docker build."""
    r = requests.post(url, json=payload)
    try:
        r.raise_for_status()
    except requests.exceptions.HTTPError as e:
        print "HTTP Error:", e.message
        raise
    return r.content


def docker_build_remote():
    """Initiate a remote docker build on quay.io."""
    payload = {"commit": "", "ref": "", "default_branch": "master"}
    # future: add support for other images
    q = load_quay_settings(os.path.join(CREDS, 'quay-ubuntu.json'))

    payload['commit'] = get_latest_sha(q['repo'], q['branch'])
    payload['ref'] = str(q['branch'])

    url = "https://%24token:{0}@quay.io/webhooks/push/trigger/{1}".format(
        q['token'], q['trigger'])

    print trigger_quay_build(url, payload)
