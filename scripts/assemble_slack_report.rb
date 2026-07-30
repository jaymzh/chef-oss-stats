#!/usr/bin/env ruby

require 'erb'
require 'date'
require 'optparse'
require 'mixlib/shellout'

INTRO_TEXT = "Here's this week's Chef OSS community report.".freeze

def present_text(text)
  stripped = text.to_s.strip
  stripped.empty? ? nil : "#{stripped}\n"
end

def normalize_spacing(text)
  text
    .gsub(/[ \t]+\n/, "\n")
    .gsub(/\n{3,}/, "\n\n")
    .strip + "\n"
end

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
intro = INTRO_TEXT
promises = present_text(
  File.read("promise_reports/#{date}.md").lines.reject do |line|
    line.strip.empty?
  end.join,
)
pipelines = present_text(
  File.read("pipeline_visibility_reports/#{date}.md").lines[2..].join,
)
s = Mixlib::ShellOut.new('./bin/meeting_stats -m summary')
meetings = present_text(s.run_command.stdout)
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
repos = present_text(repos)
external_contributions = present_text(
  File.read("external_contributors_reports/#{date}.md"),
)

template_file = File.expand_path('../templates/slack_report.erb', __dir__)
template = File.read(template_file)
output = ERB.new(template, trim_mode: '%<>').result(binding)
puts normalize_spacing(output)
