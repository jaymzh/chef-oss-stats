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

## Setting up this repo

1. Clone this repo
1. [optional] If you want to use `sugarjar`, I recommend keeping a checkout of
   [oss-stats](https://github.com/jaymzh/oss-stats) at the same level.
   The sugarjar config assumes this is the case for linting.
1. Install the deps and create the relevant binstubs:

    ```shell
    bundle install
    bundle binstubs oss-stats
    ```

## Weekly work

For simplicity the docs for the weekly work are split into a version
for those using sugarjar, and for those not using it.

Regardless of your tooling you will need your own fork of the repo to push
branches so you can make pull requests.

### Sugarjar version

1. Create a new branch

    ```shell
    sj feature weekly
    ```

1. Update the information about last week's meeting. By default,
   assumes a date of the previous Thursday, so if you're running
   this Thursday morning for the previous week you'll need to pass
   in `--date YYYY-MM-DD`

    ```shell
    ./bin/meeting_stats
    ```

1. Generate all reports for the repo with:

    ```shell
    ./scripts/run_all_weekly_reports.sh
    ```

1. Add the new reports to git and make a PR:

    ```shell
    git add *_reports/*
    git commit -as
    sj spush && sj spr
    ```

1. Generate the report for the slack team meeting

    ```shell
    ./scripts/assemble_slack_report.rb
    ```

### non-Sugarjar version

What follows assumes your `origin` remote in git is your fork and `upstream` is
this repo.

1. Create a new branch

    ```shell
    # or, alternatively, with git
    git checkout -b weekly origin/main
    ```

1. Update the information about last week's meeting. By default,
   assumes a date of the previous Thursday, so if you're running
   this Thursday morning for the previous week you'll need to pass
   in `--date YYYY-MM-DD`

    ```shell
    ./bin/meeting_stats
    ```

1. Generate all reports for the repo with:

    ```shell
    ./scripts/run_all_weekly_reports.sh
    ```

1. Add the new reports to git and make a PR:

    ```shell
    git add *_reports/*
    git commit -as
    git push origin weekly
    gh pr create -f # or, if you prefer, create the PR in the web UI
    ```

1. Generate slack team meet

    ```shell
    ./scripts/assemble_slack_report.rb
    ```
