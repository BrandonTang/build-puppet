# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class transparency_scriptworker::settings {
    $root                     = '/builds/scriptworker'
    $task_script              = "${root}/bin/transparencyscript"
    $task_script_config       = "${root}/script_config.json"
    $task_max_timeout         = 1800

    $worker_group             = 'transparencyworker-v1'
    $worker_type              = 'transparencyworker-v1'
    $taskcluster_client_id    = secret('transparencyworker_dev_taskcluster_client_id')
    $taskcluster_access_token = secret('transparencyworker_dev_taskcluster_access_token')
    $verbose_logging          = true

    $env_config = {
        'dev' => {
            transparency_aws_access_key_id     => secret('transparency-aws_access_key_id'),
            transparency_aws_secret_access_key => secret('transparency-aws_secret_access_key'),
        }
    }
}
