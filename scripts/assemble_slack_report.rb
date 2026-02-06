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
promises = File.read("promise_reports/#{date}.md").lines.reject do |line|
  line.strip.empty?
end.join
pipelines = File.read("pipeline_visibility_reports/#{date}.md").lines[2..].join
s = Mixlib::ShellOut.new('./bin/meeting_stats -m summary')
meetings = s.run_command.stdout
repos = ''
File.read("repo_reports/#{date}.md").each_line do |line|
  next unless line.start_with?('*_[')
  m = line.match(/\*\_(\[.*\]\(https.*\)) Stats/)
  if m
    repos << "* #{m[1]}\n"
  else
    puts "this line should have matched: #{line}"
  end
end
# rubocop:enable Lint/UselessAssignment

template_file = File.expand_path('../templates/slack_report.erb', __dir__)
template = File.read(template_file)
puts ERB.new(template, trim_mode: '%<>').result
