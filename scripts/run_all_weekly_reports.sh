#!/bin/bash

err() {
    echo "ERROR: $*"
}

die() {
    err "$*"
    exit 1
}

echo -n "Have you already updated meeting for last week? [Y/n] "
read ans
if ! [[ "$ans" =~ [Yy] ]]; then
    die "Please do that first" 
fi

date=$(date '+%Y-%m-%d')

echo "Running Pipeline Visibility Report"
../oss-stats/src/pipeline_visibility_stats.rb \
    -o "pipeline_visibility_reports/${date}.md"

echo "Running Meeting Report"
../oss-stats/src/meeting_stats.rb -m generate

echo "Running Promises Report"
../oss-stats/src/promises.rb -o "promises_reports/${date}.md"

output="ci_reports/${date}.md"
echo "Running CI Report"
./scripts/run_weekly_ci_reports.sh -o "$output" -- --days 7
