# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'tmpdir'

RSpec.describe 'scripts/assemble_slack_report.rb' do
  let(:date) { '2099-01-01' }
  let(:repo_root) { File.expand_path('../..', __dir__) }

  def write_file(root, relative_path, contents, executable: false)
    path = File.join(root, relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, contents)
    FileUtils.chmod('+x', path) if executable
  end

  def render_report(meeting_summary: '')
    Dir.mktmpdir('assemble-slack-report-spec') do |tmpdir|
      copy_report_files(tmpdir)
      write_report_inputs(tmpdir, meeting_summary)

      return Open3.capture2(
        'ruby',
        'scripts/assemble_slack_report.rb',
        '--date',
        date,
        chdir: tmpdir,
      )
    end
  end

  def copy_report_files(tmpdir)
    source_files = [
      'scripts/assemble_slack_report.rb',
      'templates/slack_report.erb',
    ]
    source_files.each do |path|
      write_file(
        tmpdir,
        path,
        File.read(File.join(repo_root, path)),
        executable: path.start_with?('scripts/'),
      )
    end
  end

  def write_report_inputs(tmpdir, meeting_summary)
    write_file(tmpdir, "promise_reports/#{date}.md", '')
    write_file(
      tmpdir,
      "pipeline_visibility_reports/#{date}.md",
      "# title\n\n",
    )
    write_file(tmpdir, "repo_reports/#{date}.md", '')
    write_file(tmpdir, "external_contributors_reports/#{date}.md", '')
    write_file(
      tmpdir,
      'bin/meeting_stats',
      <<~SH,
        #!/bin/sh
        printf '%s' #{meeting_summary.inspect}
      SH
      executable: true,
    )
  end

  it 'keeps links compatible with manual Slack paste' do
    stdout, status = render_report

    expect(status).to be_success
    expect(stdout).to include(
      "[#{date}](https://github.com/jaymzh/chef-oss-stats/blob/main/" \
      "pipeline_visibility_reports/#{date}.md)",
    )
    expect(stdout).not_to include(
      '<https://github.com/jaymzh/chef-oss-stats/blob/main/' \
      "pipeline_visibility_reports/#{date}.md|#{date}>",
    )
  end

  it 'keeps expected report sections when their data is blank' do
    stdout, status = render_report

    expect(status).to be_success
    expect(stdout).to include('Pending Community Promises')
    expect(stdout).to include('Pipeline Visibility')
    expect(stdout).to include('Repo Status')
    expect(stdout).to include('External contributors report')
    expect(stdout).not_to include('Slack report metrics')
  end
end
