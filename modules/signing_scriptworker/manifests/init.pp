class signing_scriptworker {
    include ::config
    include signing_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include users::signer
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include nrpe::check::signing_file_ages

    $env_config = $signing_scriptworker::settings::env_config[$signing_scriptworker_env]

    # because puppet barfs whenever I try to put it in settings.pp
    $verbose_logging = true
    $build_tools_version = '23.0.3'
    # See value defined in packages::mozilla::android_sdk
    $zipalign_location = "/tools/android-sdk/build-tools/$build_tools_version/zipalign"
    $dmg_location = "${signing_scriptworker::settings::root}/dmg/dmg"
    $hfsplus_location = "${signing_scriptworker::settings::root}/dmg/hfsplus"

    python35::virtualenv {
        "${signing_scriptworker::settings::root}":
            python3  => "${packages::mozilla::python35::python3}",
            require  => Class["packages::mozilla::python35"],
            user     => "${users::signer::username}",
            group    => "${users::signer::group}",
            mode     => 700,
            packages => [
                  "PyYAML==3.12",
                  "aiohttp==2.1.0",
                  "arrow==0.10.0",
                  "async-timeout==1.2.1",
                  "certifi==2017.4.17",
                  "chardet==3.0.4",
                  "defusedxml==0.5.0",
                  "ecdsa==0.13",
                  "frozendict==1.2",
                  "future==0.16.0",
                  "jsonschema==2.6.0",
                  "idna==2.5",
                  "mohawk==0.3.4",
                  "multidict==2.1.6",
                  "pefile==2016.7.26",
                  "pexpect==4.2.1",
                  "ptyprocess==0.5.1",
                  "pycrypto==2.6.1",
                  "pyparsing==2.2.0",
                  "python-dateutil==2.6.0",
                  "python-gnupg==0.4.0",
                  "python-jose==1.3.2",
                  "requests==2.18.1",
                  "scriptworker==4.1.2",
                  "signingscript==2.0.0",
                  "signtool==3.1.0",
                  "six==1.10.0",
                  "slugid==1.0.7",
                  "taskcluster==1.3.3",
                  "urllib3==1.21.1",
                  "virtualenv==15.1.0",
                  "yarl==0.10.3",
            ];
    }

    scriptworker::instance {
        "${signing_scriptworker::settings::root}":
            instance_name            => $module_name,
            basedir                  => $signing_scriptworker::settings::root,

            task_script              => $signing_scriptworker::settings::task_script,
            task_script_config       => $signing_scriptworker::settings::task_script_config,

            username                 => $users::signer::username,
            group                    => $users::signer::group,

            taskcluster_client_id    => $env_config['taskcluster_client_id'],
            taskcluster_access_token => $env_config['taskcluster_access_token'],
            worker_group             => $signing_scriptworker::settings::worker_group,
            worker_type              => $env_config['worker_type'],
            task_max_timeout         => $signing_scriptworker::settings::task_max_timeout,

            cot_job_type             => "signing",

            sign_chain_of_trust      => $env_config["sign_chain_of_trust"],
            verify_chain_of_trust    => $env_config["verify_chain_of_trust"],
            verify_cot_signature     => $env_config["verify_cot_signature"],

            verbose_logging          => $signing_scriptworker::settings::verbose
    }

    nrpe::custom {
        "signingworker.cfg":
            content => template("${module_name}/nagios.cfg.erb");
    }

    file {
        "${signing_scriptworker::settings::root}/script_config.json":
            require     => Python35::Virtualenv["${signing_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}",
            content     => template("${module_name}/script_config.json.erb"),
            show_diff   => true;
        "${signing_scriptworker::settings::root}/passwords.json":
            require     => Python35::Virtualenv["${signing_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}",
            content     => template("${module_name}/${env_config['passwords_template']}"),
            show_diff => false;
        "${signing_scriptworker::settings::root}/dmg":
            ensure      => directory,
            mode        => 755,
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}";
        "${dmg_location}":
            mode        => 755,
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}",
            source      => "puppet:///modules/signing_scriptworker/dmg/dmg",
            show_diff   => false;
        "${hfsplus_location}":
            mode        => 755,
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}",
            source      => "puppet:///modules/signing_scriptworker/dmg/hfsplus",
            show_diff   => false;
    }

    packages::mozilla::android_sdk {
      $build_tools_version:
        username          => $users::signer::username,
        group             => $users::signer::group,
        zipalign_location => $zipalign_location;
    }
}
