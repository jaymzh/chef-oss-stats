#!/usr/bin/env ruby

require 'erb'
require 'date'
require 'optparse'
require 'mixlib/shellout'

options = {}
OptionParser.new do |opts|
  opts.on(
    '--date DATE',
    'This date will be used to pull data from pre-built reports. Is not ' +
    'applicable to the meeting report which is always last-3-weeks from ' +
    'today',
  ) do |d|
    options[:date] = d
  end
end.parse!

date = options[:date] || Date.today.to_s
# rubocop:disable Lint/UselessAssignment
promises = File.read("promises_reports/#{date}.md").lines[2..].join
pipelines = File.read("pipeline_visibility_reports/#{date}.md").lines[2..].join
s = Mixlib::ShellOut.new('../oss-stats/src/meeting_stats.rb -m summary')
meetings = s.run_command.stdout
# rubocop:enable Lint/UselessAssignment

template_file = File.expand_path('../templates/slack_report.erb', __dir__)
template = File.read(template_file)
puts ERB.new(template, trim_mode: '%<>').result
