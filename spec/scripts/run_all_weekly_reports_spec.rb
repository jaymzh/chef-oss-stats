# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'tmpdir'

RSpec.describe 'scripts/run_all_weekly_reports.sh' do
  let(:repo_root) { File.expand_path('../..', __dir__) }

  def write_executable(root, path, contents)
    target = File.join(root, path)
    FileUtils.mkdir_p(File.dirname(target))
    File.write(target, contents)
    FileUtils.chmod('+x', target)
  end

  def run_reports(buildkite_token: nil)
    Dir.mktmpdir('all-weekly-reports-spec') do |tmpdir|
      %w{
        external_contributors_reports
        pipeline_visibility_reports
        promise_reports
        repo_reports
      }.each { |directory| FileUtils.mkdir_p(File.join(tmpdir, directory)) }

      write_executable(
        tmpdir,
        'scripts/run_all_weekly_reports.sh',
        File.read(File.join(repo_root, 'scripts/run_all_weekly_reports.sh')),
      )
      write_executable(tmpdir, 'bin/meeting_stats', "#!/bin/sh\nexit 0\n")
      write_executable(tmpdir, 'bin/promise_stats', "#!/bin/sh\nexit 0\n")
      write_executable(
        tmpdir,
        'bin/pipeline_visibility_stats',
        "#!/bin/sh\nprintf '%s\\n' \"$@\" > pipeline-args.txt\n",
      )
      write_executable(
        tmpdir,
        'scripts/run_weekly_repo_reports.sh',
        "#!/bin/sh\nexit 0\n",
      )
      write_executable(
        tmpdir,
        'scripts/non-progress-stats.rb',
        "#!/bin/sh\necho contributors\n",
      )

      env = { 'BUILDKITE_API_TOKEN' => buildkite_token }
      stdout, stderr, status = Open3.capture3(
        env,
        './scripts/run_all_weekly_reports.sh',
        '--yes',
        chdir: tmpdir,
      )
      report = Dir[File.join(tmpdir, 'pipeline_visibility_reports/*.md')]
               .then { |paths| paths.empty? ? '' : File.read(paths.first) }
      args_path = File.join(tmpdir, 'pipeline-args.txt')
      args = File.exist?(args_path) ? File.read(args_path) : ''
      return stdout, stderr, status, report, args
    end
  end

  it 'writes a skip notice when Buildkite is unavailable' do
    stdout, _stderr, status, report, args = run_reports

    expect(status).to be_success
    expect(stdout).to include('Skipping Pipeline Visibility Report')
    expect(report).to include('no Buildkite API token was available')
    expect(args).to be_empty
  end

  it 'passes an available Buildkite token explicitly' do
    _stdout, _stderr, status, _report, args = run_reports(
      buildkite_token: 'test-token',
    )

    expect(status).to be_success
    expect(args.lines.map(&:chomp)).to include(
      '--buildkite-token',
      'test-token',
    )
  end
end
