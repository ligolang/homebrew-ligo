#!/usr/bin/env bash

# Check latest release and compare it to the current version
latest_release_name="$(curl -X GET "https://gitlab.com/api/v4/projects/12294987/releases" | jq --raw-output '.[0].tag_name')"
latest_release_revision="$(curl -X GET "https://gitlab.com/api/v4/projects/12294987/releases" | jq --raw-output '.[0].commit.id')"
current_release_name="$(ggrep -Po 'tag: "\K.*?(?=")' Formula/ligo.rb)"

if [ "$current_release_name" = "$latest_release_name" ]; then
    echo "Release is up to date, doing nothing"
else
    echo "New release detected, updating!"

    gsed -i "s|tag: \".*\", revision: \".*\"|tag: \"${latest_release_name}\", revision: \"${latest_release_revision}\"|g" Formula/ligo.rb
fi

latest_next_commit_hash="$(curl -X GET "https://gitlab.com/api/v4/projects/12294987/repository/commits" | jq --raw-output '.[0].id')"
current_next_commit_hash="$(ggrep -Po 'revision: "\K.*?(?=")' Formula/ligo_next.rb)"

if [ "$current_next_commit_hash" = "$latest_next_commit_hash" ]; then
    echo "Next is up to date, doing nothing"
else
    echo "New commit detected, updating!"
    gsed -i "s|${current_next_commit_hash}|${latest_next_commit_hash}|g" Formula/ligo_next.rb
fi