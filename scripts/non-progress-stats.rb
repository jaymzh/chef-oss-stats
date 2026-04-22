#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'json'
require 'logger'
require 'open3'
require 'optparse'
require 'time'
require 'yaml'
require 'oss_stats/config/repo_stats'

days = 7
include_none = false
log_level = Logger::WARN
account_info_file = File.join(Dir.pwd, 'gh_account_info.yml')
OptionParser.new do |opts|
  opts.on('-d', '--days DAYS', Integer, 'Number of days to look back') do |d|
    days = d
  end
  opts.on('-c', '--config FILE',
          'Path to account info YAML (default: gh_account_info.yml)') do |f|
    account_info_file = f
  end
  opts.on('-l', '--log-level LEVEL',
           'Log level: debug, info, warn (default: warn)') do |l|
    log_level = Logger.const_get(l.upcase)
  end
  opts.on(
    '--include-none',
    'Include repos with zero non-Progress contributions',
  ) do
    include_none = true
  end
end.parse!

log = Logger.new($stderr)
log.level = log_level
log.formatter = proc { |severity, _, _, msg| "[#{severity}] #{msg}\n" }

unless File.exist?(account_info_file)
  log.error("account info file not found: #{account_info_file}")
  exit 1
end
account_info = YAML.safe_load_file(account_info_file)
BOT_ACCOUNTS = (account_info['bot_accounts'] || []).map(&:downcase).freeze
PROGRESS_ACCOUNTS =
  (account_info['progress_accounts'] || []).map(&:downcase).freeze

cutoff = (Time.now.utc - (days * 86400))

config_file = OssStats::Config::RepoStats.config_file
if config_file.nil? || !File.exist?(config_file.to_s)
  log.error('could not find repo_stats_config.rb')
  exit 1
end
OssStats::Config::RepoStats.from_file(config_file)
organizations = OssStats::Config::RepoStats.organizations

def fetch_pr_logins(owner, repo, field, cutoff, log)
  order_field = field == 'createdAt' ? 'CREATED_AT' : 'UPDATED_AT'
  cursor = nil
  logins = []

  loop do
    cursor_arg = cursor ? "\"#{cursor}\"" : 'null'
    query = <<~GRAPHQL
      query {
        repository(owner: "#{owner}", name: "#{repo}") {
          pullRequests(first: 100, after: #{cursor_arg}, orderBy: {field: #{order_field}, direction: DESC}) {
            pageInfo { hasNextPage endCursor }
            nodes {
              author { login }
              createdAt
              mergedAt
            }
          }
        }
      }
    GRAPHQL

    stdout, stderr, status = Open3.capture3(
      'gh', 'api', 'graphql', '-f', "query=#{query}"
    )

    unless status.success?
      log.warn("gh api failed for #{owner}/#{repo}: #{stderr.strip}")
      return logins
    end

    response = JSON.parse(stdout)

    if response['errors']
      errors = response['errors'].map { |e| e['message'] }.join(', ')
      log.warn("GraphQL errors for #{owner}/#{repo}: #{errors}")
      return logins
    end

    prs = response.dig('data', 'repository', 'pullRequests')
    unless prs
      log.warn("no pullRequests data for #{owner}/#{repo}")
      return logins
    end

    stop = false
    prs['nodes'].each do |node|
      login = node.dig('author', 'login')
      next unless login

      ts_str = node[field]
      next unless ts_str

      ts = Time.parse(ts_str).utc

      if field == 'createdAt'
        if ts < cutoff
          stop = true
          break
        end
        logins << login
      elsif ts >= cutoff
        logins << login
      end
    end

    break unless prs.dig('pageInfo', 'hasNextPage')
    break if field == 'createdAt' && stop

    cursor = prs.dig('pageInfo', 'endCursor')
  end

  logins
end

def compute_stats(owner, repo, _days, cutoff, log)
  authored = fetch_pr_logins(owner, repo, 'createdAt', cutoff, log)
  merged = fetch_pr_logins(owner, repo, 'mergedAt', cutoff, log)

  {
    authored: authored,
    merged: merged,
  }
end

def summarize(_label, logins)
  real = logins.reject { |l| BOT_ACCOUNTS.include?(l.downcase) }
  bots = logins.select { |l| BOT_ACCOUNTS.include?(l.downcase) }
  non_progress = real.reject { |l| PROGRESS_ACCOUNTS.include?(l.downcase) }

  pct = real.empty? ? 0 : (non_progress.size * 100 / real.size)

  {
    real_count: real.size,
    bot_count: bots.size,
    non_progress_count: non_progress.size,
    pct: pct,
    non_progress_logins: non_progress,
  }
end

puts "*_Non-Progress contributions in the last #{days} days:_*\n\n"

total_authored = []
total_merged = []
repo_results = []

organizations.each do |org, org_config|
  repos = org_config['repositories'] || {}
  repos.each_key do |repo|
    log.info("Fetching #{org}/#{repo}...")
    stats = compute_stats(org, repo, days, cutoff, log)
    a = summarize('authored', stats[:authored])
    m = summarize('merged', stats[:merged])
    all_np = (a[:non_progress_logins] + m[:non_progress_logins]).uniq.sort
    next if all_np.empty? && !include_none

    repo_results << { org: org, repo: repo, stats: stats, a: a, m: m,
                      all_np: all_np }
    total_authored.concat(stats[:authored])
    total_merged.concat(stats[:merged])
  end
end

repo_results.each do |r|
  a = r[:a]
  m = r[:m]

  puts "* *#{r[:org]}/#{r[:repo]}*"
  puts "    * Authored PRs: #{a[:pct]}% [#{a[:non_progress_count]} of" \
       " #{a[:real_count]}] (not including #{a[:bot_count]} from automation)"
  puts "    * Merged PRs:   #{m[:pct]}% [#{m[:non_progress_count]} of" \
       " #{m[:real_count]}] (not including #{m[:bot_count]} from automation)"
  puts "    * Contributors: #{r[:all_np].join(', ')}" unless r[:all_np].empty?
  puts
end

ta = summarize('authored', total_authored)
tm = summarize('merged', total_merged)
all_np_total = (ta[:non_progress_logins] + tm[:non_progress_logins]).uniq.sort

puts "*_TOTALS_*\n\n"
puts "* Authored PRs: #{ta[:pct]}% [#{ta[:non_progress_count]} of" \
     " #{ta[:real_count]}] (not including #{ta[:bot_count]} from automation)"
puts "* Merged PRs:   #{tm[:pct]}% [#{tm[:non_progress_count]} of" \
     " #{tm[:real_count]}] (not including #{tm[:bot_count]} from automation)"
puts "* Contributors: #{all_np_total.join(', ')}" unless all_np_total.empty?
puts
