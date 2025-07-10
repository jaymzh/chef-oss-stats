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
../oss-stats/bin/pipeline_visibility_stats \
    --skip adhoc --skip private --skip release \
    --buildkite-org chef-oss --github-org chef \
    -o "pipeline_visibility_reports/${date}.md"
# the old one...
# ../oss-stats/bin/pipeline_visibility_stats \
#    --skip adhoc --skip private --skip release \
#    --provider expeditor --github-org chef \
#    -o "pipeline_visibility_reports/${date}.md"

echo "Running Meeting Report"
../oss-stats/bin/meeting_stats -m generate

echo "Running Promises Report"
../oss-stats/bin/promise_stats -o "promise_reports/${date}.md"

echo "Running CI Report"
./scripts/run_weekly_repo_reports.sh -o "repo_reports/${date}.md" "${@}"
