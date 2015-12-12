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

#    @Command('trigger-build', category='deploy',
#             description='Schedule jenkins index run')
#    @CommandArgument('jobs', nargs='*',
#                     help='Jobs to schedule')
#    @CommandArgument('--verbosity', type=int,
#                     help='How verbose to be with output')
#    def trigger_build(self, jobs, verbosity=None):
#        from deploy import deploy_trigger_build as trigger_build
#        return trigger_build(jobs, verbosity=verbosity)

    @Command('trigger-all', category='jenkins',
             description='Schedule all Jenkins jobs to run')
    @CommandArgument('--verbosity', type=int,
                     help='How verbose to be with output')
    def trigger_all(self, verbosity=None):
        from deploy import deploy_trigger_all as trigger_all
        return trigger_all(verbosity=verbosity)
