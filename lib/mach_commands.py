# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

from mach.decorators import (
    CommandArgument,
    CommandProvider,
    Command,
)


@CommandProvider
class DeployCommands(object):
    def __init__(self, context):
        lm = context.log_manager
        lm.enable_unstructured()

    @Command('dxrmo', category='deploy',
             description='Deploy dxr.mozilla.org')
    @CommandArgument('--verbosity', type=int,
                     help='How verbose to be with output')
    def dxrmo(self, verbosity=None):
        # from vcttesting.deploy import deploy_hgmo as deploy
        from deploy import deploy_dxrmo as deploy
        return deploy(verbosity=verbosity)

    @Command('update-config', category='deploy',
             description='Regenerate DXR and Jenkins configs')
    @CommandArgument('--verbosity', type=int,
                     help='How verbose to be with output')
    def update_config(self, verbosity=None):
        from deploy import deploy_update_config as update_config
        return update_config(verbosity=verbosity)

    @Command('restart-builder', category='deploy',
             description='Restart docker on a builder node')
    @CommandArgument('node',
                     help='Node on which to restart docker')
    @CommandArgument('--verbosity', type=int,
                     help='How verbose to be with output')
    def restart_builder(self, node, verbosity=None):
        from deploy import deploy_restart_builder as restart_builder
        return restart_builder(node, verbosity=verbosity)

    @Command('trigger-job', category='jenkins',
             description='Schedule a Jenkins job to run')
    @CommandArgument('job',
                     help='Jenkins job to schedule')
    @CommandArgument('--verbosity', type=int,
                     help='How verbose to be with output')
    def trigger_job(self, job, verbosity=None):
        from deploy import deploy_trigger_job as trigger_job
        return trigger_job(job, verbosity=verbosity)

    @Command('trigger-all-jobs', category='jenkins',
             description='Schedule all Jenkins jobs to run')
    @CommandArgument('--verbosity', type=int,
                     help='How verbose to be with output')
    def trigger_all_jobs(self, verbosity=None):
        from deploy import deploy_trigger_all_jobs as trigger_all_jobs
        return trigger_all_jobs(verbosity=verbosity)

    @Command('test-job', category='jenkins',
             description='Test Jenkins job(s) config')
    @CommandArgument('--log_level', nargs='?', type=str, default='INFO',
                     choices=['INFO', 'WARNING', 'ERROR', 'CRITICAL', 'DEBUG'],
                     help='How verbose to be with output (default: INFO)')
    @CommandArgument('jobs', nargs='*',
                     help='Job configuration(s) to test')
    def test_job(self, jobs, log_level):
        from jjb import jjb_test_job_config as test_job_config
        return test_job_config(jobs, log_level=log_level)

    @Command('update-job', category='jenkins',
             description='Update Jenkins job(s)')
    @CommandArgument('--log_level', nargs='?', type=str, default='INFO',
                     choices=['INFO', 'WARNING', 'ERROR', 'CRITICAL', 'DEBUG'],
                     help='How verbose to be with output (default: INFO)')
    @CommandArgument('jobs', nargs='*',
                     help='Job(s) to update')
    def update_job(self, jobs, log_level):
        from jjb import jjb_update_job_config as update_job_config
        return update_job_config(jobs, log_level=log_level)

    @Command('delete-job', category='jenkins',
             description='Delete Jenkins job')
    @CommandArgument('--log_level', nargs='?', type=str, default='INFO',
                     choices=['INFO', 'WARNING', 'ERROR', 'CRITICAL', 'DEBUG'],
                     help='How verbose to be with output (default: INFO)')
    @CommandArgument('jobs', nargs='*',
                     help='Job(s) to delete')
    def delete_job(self, jobs, log_level):
        from jjb import jjb_delete_job_config as delete_job_config
        return delete_job_config(jobs, log_level=log_level)
