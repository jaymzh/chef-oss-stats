# Chef's OSS Stats

[![Lint](https://github.com/jaymzh/chef-oss-stats/actions/workflows/lint.yml/badge.svg)](https://github.com/jaymzh/chef-oss-stats/actions/workflows/lint.yml)
[![DCO Check](https://github.com/jaymzh/chef-oss-stats/actions/workflows/dco.yml/badge.svg)](https://github.com/jaymzh/chef-oss-stats/actions/workflows/dco.yml)

This repo aims to track stats that affect how Chef Users ("the community") can
interact with Progress' development teams and repositories.

It leverages [oss-stats](https://github.com/jaymzh/oss-stats) to track those
stats. It assumes oss-stats and this repo are checked out next to each other
on the filesystem.

## tl;dr

* See **Issue, PR, and CI stats** in [repo_reports](repo_reports)
* See **weekly meeting stats** in [Slack Status Tracking](team_slack_reports.md)
* See **pipeline visiblity stats** in [pipeline_visibility_reports](pipeline_visibility_reports)
* See **promise stats** in [promise_reports](promise_reports)

## Usage

For updated information on using these scripts see the [oss-stats
README](https://github.com/jaymzh/oss-stats/blob/main/README.md).

## Extra scripts in this repo

* [run_weekly_repo_reports.sh](scripts/run_weekly_repo_reports.sh) loops over
  all relevant repos and runs ci_stats.rb on them.
* [run_all_weekly_reports.sh](scripts/run_all_weekly_reports.sh) runs all
  report generators including `run_weekly_ci_reports`
* [assemble_slack_report.rb](scripts/assemble_slack_report.rb) generates most
  of the slack report.

## Weekly work

Each week...

```shell
# Create a new branch
sj feature weekly

# Update information about last meeting with:
../oss-stats/bin/meeting_stats

# Generate all reports for the repo with:
./scripts/run_all_weekly_reports.sh
git add *_reports/*

# Create a PR
git commit -as
sj spush && sj spr

# Generate slack team meet
./scripts/assemble_slack_report.rb
```
