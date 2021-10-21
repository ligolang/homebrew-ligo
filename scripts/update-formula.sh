# Install utils needed for script
brew install jq coreutils gnu-sed || exit 0

# Check latest release and compare it to the current version
latest_release_name=$(curl -X GET "https://gitlab.com/api/v4/projects/12294987/releases" | jq --raw-output '.[0].tag_name')
current_release_url=$(cat Formula/ligo.rb | grep -m 1 " url" | cut -d "\"" -f 2)
release_archive_url="https://gitlab.com/ligolang/ligo/-/archive/${latest_release_name}/ligo-${latest_release_name}.tar.gz"

if [ "$current_release_url" = "$release_archive_url" ]; then
    echo "Release is up to date, doing nothing"
else
    echo "New release detected, updating!"
    release_sha256=$(curl -L --fail $archive_url | sha256sum | cut -d " " -f 1)

    gsed -i "s| url \".*\"| url \"${release_archive_url}\"|g" ./Formula/ligo.rb
    gsed -i "s|sha256 \".*\"|sha256 \"${release_sha256}\"|g" ./Formula/ligo.rb
fi

next_commit_hash=$(curl -X GET "https://gitlab.com/api/v4/projects/12294987/repository/commits" | jq --raw-output '.[0].id')
current_next_archive_url=$(cat Formula/ligo_next.rb | grep -m 1 " url" | cut -d "\"" -f 2)
next_archive_url="https://gitlab.com/ligolang/ligo/-/archive/${next_commit_hash}/ligo-${next_commit_hash}.tar.gz"

if [ "$current_next_archive_url" = "$next_archive_url" ]; then
    echo "Next is up to date, doing nothing"
else
    echo "New commit detected, updating!"
    next_sha256=$(curl -L --fail $next_archive_url | sha256sum | cut -d " " -f 1)

    gsed -i "s| version \".*\"| version \"${next_commit_hash}\"|g" ./Formula/ligo_next.rb
    gsed -i "s| url \".*\"| url \"${next_archive_url}\"|g" ./Formula/ligo_next.rb
    gsed -i "s|sha256 \".*\"|sha256 \"${next_sha256}\"|g" ./Formula/ligo_next.rb
fi