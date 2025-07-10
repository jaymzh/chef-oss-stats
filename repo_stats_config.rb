buildkite_org 'chef-oss'
default_days 7
include_list false
top_n_stale_pr 1
top_n_oldest_pr 1
top_n_time_to_close_pr 1
top_n_most_broken_ci_days 3
top_n_most_broken_ci_jobs 3
mode %w{pr ci}
organizations({
                'chef' => {
                  'repositories' => {
                    'chef' => {
                      'branches' => %w{main chef-18},
                    },
                    'ohai' => {
                      'branches' => %w{main chef-18},
                    },
                    'cheffish' => {},
                    'cookstyle' => {},
                    'cookstylist' => {},
                    'chef-plans' => {},
                    'vscode-chef' => {},
                    'chef-powershell-shim' => {},
                    'mixlib-shellout' => {},
                    'mixlib-archive' => {},
                    'mixlib-versioning' => {},
                    'mixlib-log' => {},
                    'mixlib-install' => {},
                    'mixlib-config' => {},
                    'mixlib-cli' => {},
                    'win32-service' => {},
                    'win32-certstore' => {},
                    'win32-ipc' => {},
                    'win32-taskscheduler' => {},
                    'win32-process' => {},
                    'win32-event' => {},
                    'win32-api' => {},
                    'win32-eventlog' => {},
                    'ffi-win32-extensions' => {},
                    'chef-zero' => {},
                    'ffi-yajl' => {},
                    'fauxhai' => {},
                  },
                },
                'habitat-sh' => {
                  'repositories' => {
                    'habitat' => {},
                    'core-plans' => {},
                    'homebrew-habitat' => {},
                  },
                },
                'inspec' => {
                  'repositories' => {
                    'inspec' => {},
                    'inspec-digitalocean' => {},
                    'inspec-habitat' => {},
                    'inspec-oneview' => {},
                    'inspec-vmware' => {},
                    'kitchen-inspec' => {},
                    'train-aws' => {},
                    'train-habitat' => {},
                    'train-digitalocean' => {},
                    'inspec-aws' => {},
                    'inspec-azure' => {},
                    'inspec-gcp' => {},
                  },
                },
              })
