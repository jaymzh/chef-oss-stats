#!/bin/bash

set -e

err() {
    echo "ERROR: $*"
}

die() {
    err "$*"
    exit 1
}

if [[ "${1:-}" == "--yes" ]]; then
    ans=Y
    shift
else
    echo -n "Have you already updated meeting for last week? [Y/n] "
    read -r ans
fi

if ! [[ "$ans" =~ [Yy] ]]; then
    die "Please do that first" 
fi

date=$(date '+%Y-%m-%d')

if [[ -n "${BUILDKITE_API_TOKEN:-}" ]]; then
    echo "Running Pipeline Visibility Report"
    ./bin/pipeline_visibility_stats \
        --skip adhoc --skip private --skip release \
        --skip-repos cac-meeting-tracker \
        --buildkite-org chef-oss --github-org chef \
        --buildkite-token "$BUILDKITE_API_TOKEN" \
        -o "pipeline_visibility_reports/${date}.md"
else
    echo "Skipping Pipeline Visibility Report (Buildkite token unavailable)"
    cat > "pipeline_visibility_reports/${date}.md" <<EOF
# Chef Pipeline Visibility Report ${date}

Buildkite pipeline visibility checks were skipped because no Buildkite API token was available.
EOF
fi

echo "Running Meeting Report"
./bin/meeting_stats -m generate

echo "Running Promises Report"
./bin/promise_stats status -o "promise_reports/${date}.md"

echo "Running CI Report"
./scripts/run_weekly_repo_reports.sh -o "repo_reports/${date}.md" "${@}"

echo "Running external contributors Report"
./scripts/non-progress-stats.rb "${@}" \
    > "external_contributors_reports/${date}.md"
