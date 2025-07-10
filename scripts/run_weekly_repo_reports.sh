#!/bin/bash

REPO_SCRIPT=repo_stats
MYDIR="$(dirname $(realpath $0))"
REPO_SCRIPT_PATH="$MYDIR/../../oss-stats/bin/$REPO_SCRIPT"
OUTPUT=''

ourhelp() {
    cat <<EOF
This is a dumb wrapper around ${REPO_SCRIPT}!

It has no options itself. It will call $REPO_SCRIPT for all repos
it knows about. It will pass any options to this script to all calls
to $REPO_SCRIPT.
EOF
}

output() {
    if [ -z "$OUTPUT" ]; then
        echo -e "$*"
    else
        echo -e "$*" >> "$OUTPUT"
    fi
}

while getopts 'ho:' opt; do
    case "$opt" in
        h)
            ourhelp
            exit
            ;;
        o)
            OUTPUT="$OPTARG"
            ;;
        ?)
            ourhelp
            exit 1
    esac
done

# remove those args so we can pass the rest to the script
shift $((OPTIND - 1))

if [ -n "$OUTPUT" ] && [ -e "$OUTPUT" ]; then
    rm "$OUTPUT"
fi

date=$(date '+%Y-%m-%d')
header="# Weekly Chef Repo Statuses - $date

If you see a deprecated repo or don't see a current repo, please update the
repo lists in
[chef-oss-practices/projects](https://github.com/chef/chef-oss-practices/tree/main/projects)
and
[chef/community_pr_review_checklist](https://github.com/chef/chef/blob/main/docs/dev/how_to/community_pr_review_checklist.md)
and then file an Issue (or PR) in
[jaymzh/chef-oss-stats](https://github.com/jaymzh/chef-oss-stats)."

output "$header\n"
res=$($REPO_SCRIPT_PATH "${@}")
output "$res\n"
