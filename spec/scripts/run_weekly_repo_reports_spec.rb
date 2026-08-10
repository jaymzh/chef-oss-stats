# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'tmpdir'

RSpec.describe 'scripts/run_weekly_repo_reports.sh' do
  let(:repo_root) { File.expand_path('../..', __dir__) }

  def run_wrapper(repo_stats_script)
    Dir.mktmpdir('weekly-repo-reports-spec') do |tmpdir|
      FileUtils.mkdir_p(File.join(tmpdir, 'scripts'))
      FileUtils.mkdir_p(File.join(tmpdir, 'bin'))
      FileUtils.cp(
        File.join(repo_root, 'scripts/run_weekly_repo_reports.sh'),
        File.join(tmpdir, 'scripts/run_weekly_repo_reports.sh'),
      )
      File.write(File.join(tmpdir, 'bin/repo_stats'), repo_stats_script)
      FileUtils.chmod('+x', File.join(tmpdir, 'bin/repo_stats'))

      output = File.join(tmpdir, 'report.md')
      stdout, stderr, status = Open3.capture3(
        './scripts/run_weekly_repo_reports.sh',
        '-o',
        output,
        chdir: tmpdir,
      )
      report = File.exist?(output) ? File.read(output) : ''
      return stdout, stderr, status, report
    end
  end

  it 'propagates a repo_stats failure' do
    _stdout, stderr, status, report = run_wrapper(<<~SH)
      #!/bin/sh
      echo 'repo_stats failed' >&2
      exit 42
    SH

    expect(status.exitstatus).to eq(1)
    expect(stderr).to include('repo_stats failed')
    expect(report).to be_empty
  end

  it 'rejects an empty repo_stats report' do
    _stdout, stderr, status, report = run_wrapper(<<~SH)
      #!/bin/sh
      exit 0
    SH

    expect(status.exitstatus).to eq(1)
    expect(stderr).to include('repo_stats produced no report output')
    expect(report).to be_empty
  end

  it 'writes a successful repo_stats report' do
    _stdout, _stderr, status, report = run_wrapper(<<~SH)
      #!/bin/sh
      echo 'complete report'
    SH

    expect(status).to be_success
    expect(report).to include('complete report')
  end
end
