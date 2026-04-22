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
                    'chef' => { 'branches' => %w{main chef-18} },
                    'chef-plans' => {},
                    'chef-powershell-shim' => {},
                    'chef-zero' => {},
                    'cheffish' => {},
                    'chefspec' => {},
                    'cookstyle' => {},
                    'cookstylist' => {},
                    'fauxhai' => {},
                    'ffi-win32-extensions' => {},
                    'ffi-yajl' => {},
                    'knife' => {},
                    'knife-azure' => {},
                    'knife-cloud' => {},
                    'knife-google' => {},
                    'knife-openstack' => {},
                    'knife-vcenter' => {},
                    'knife-vrealize' => {},
                    'knife-vsphere' => {},
                    'knife-windows' => {},
                    'kitchen-vcenter' => {},
                    'kitchen-dokken' => {},
                    'chef-test-kitchen-enterprise' => {},
                    'kitchen-zone' => {},
                    'mixlib-archive' => {},
                    'mixlib-authentication' => {},
                    'mixlib-cli' => {},
                    'mixlib-config' => {},
                    'mixlib-install' => {},
                    'mixlib-log' => {},
                    'mixlib-shellout' => {},
                    'mixlib-versioning' => {},
                    'ohai' => { 'branches' => %w{main 18-stable} },
                    'vscode-chef' => {},
                    'win32-api' => {},
                    'win32-certstore' => {},
                    'win32-event' => {},
                    'win32-eventlog' => {},
                    'win32-ipc' => {},
                    'win32-process' => {},
                    'win32-service' => {},
                    'win32-taskscheduler' => {},
                  },
                },
                'habitat-sh' => {
                  'repositories' => {
                    'core-plans' => {},
                    'habitat' => {},
                    'homebrew-habitat' => {},
                  },
                },
                'inspec' => {
                  'repositories' => {
                    'inspec' => {},
                    'inspec-aws' => {},
                    'inspec-azure' => {},
                    'inspec-digitalocean' => {},
                    'inspec-gcp' => {},
                    'inspec-habitat' => {},
                    'inspec-oneview' => {},
                    'inspec-vmware' => {},
                    'kitchen-inspec' => {},
                    'train-aws' => {},
                    'train-digitalocean' => {},
                    'train-habitat' => {},
                  },
                },
              })
