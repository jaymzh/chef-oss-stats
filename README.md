# Chef's OSS Stats

[![Lint](https://github.com/jaymzh/chef-oss-stats/actions/workflows/lint.yml/badge.svg)](https://github.com/jaymzh/chef-oss-stats/actions/workflows/lint.yml)
[![DCO Check](https://github.com/jaymzh/chef-oss-stats/actions/workflows/dco.yml/badge.svg)](https://github.com/jaymzh/chef-oss-stats/actions/workflows/dco.yml)

This repo aims to track stats that affect how Chef Users ("the community") can
interact with Progress' development teams and repositories.

It leverages [oss-stats](https://github.com/jaymzh/oss-stats) to track those
stats. It assumes oss-stats and this repo are checked out next to each other
on the filesystem.

## tl;dr

* See **Issue, PR, and CI stats** in [ci_reports](ci_reports)
* See **weekly meeting stats** in [Slack Status Tracking](team_slack_reports.md)
* See **pipeline visiblity stats** in [pipeline_visibility_reports](pipeline_visibility_reports)
* See **promises** in [promises][promises]

## Issue, PR, and CI Status

### Description

One measure of project health is how often CI is broken. In addition, how long
PRs and Issues sit is another metric worth looking at. These are tracked adn
reported in [ci_reports](ci_reports).

### Updating the report

The [run_weekly_ci_reports.sh](run_weekly_ci_reports.sh) wrapper script runs
the `ci_stats` script on all relevant repos, and weekly we run that and put the
results in a dated file in the [ci_reports](ci_reports) directory.

## Slack Meeting Stats

### Description

One of the few ways in which Progress communicates with users is via the weekly
slack "community meetings" where each team gives an update.

We've asked that in that report the teams include the current CI status, and if
broken, what work is being done to fix it. These stats are collected weekly and
then generated into [Slack Status Tracking](team_slack_reports.md)

### Updating the report

To record a new meeting, run `../oss-stats/src/meeting_stats.rb -m record`.

To update the report with the new data, run `../oss-stats/src/meeting_stats.rb
-m generate`.

## Pipeline visibility stats

### Description

One common frustration among Chef contributors is that sometimes Buildkite
pipelines that run tests on PRs are private, so if they fail the contributor
cannot determine what the problem is.

This metric tracks the number of those, and we put the results in
[pipeline_visibility_reports](pipeline_visibility_reports).

### Updating the report

Simply run `../oss-stats/src/pipeline_visibility_stats.rb`

## Promises

Promises are tracked in [Promises](promises).

Add a new promise with `promises.rb -m add-promise`, or run with no arguments
to get a report.
