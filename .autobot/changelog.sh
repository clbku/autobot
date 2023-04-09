#!/bin/bash

# get latest tag and commit messages
latestTag=$(git describe --long | awk -F"-" '{print $1}')
output=$(git log ${latestTag}..HEAD --format=%B%H----DELIMITER----)

# split commits by delimiter and format them
IFS=$'\n'
commitsArray=($(echo "$output" | sed 's/----DELIMITER----//g'))
features=()
chores=()

for commit in "${commitsArray[@]}"; do
  message=$(echo "$commit" | head -1)
  sha=$(echo "$commit" | tail -1)

  if [[ "$message" == feature:* ]]; then
    features+=("* $(echo "$message" | sed 's/^feature: //') ([${sha:0:6}](https://github.com/jackyef/changelog-generator/commit/$sha))")
  fi

  if [[ "$message" == chore:* ]]; then
    chores+=("* $(echo "$message" | sed 's/^chore: //') ([${sha:0:6}](https://github.com/jackyef/changelog-generator/commit/$sha))")
  fi
done

# create new version and changelog
currentChangelog=$(cat ./CHANGELOG.md)
currentVersion=$(node -p "require('./package.json').version")
newVersion=$((currentVersion + 1))
newChangelog="# Version $newVersion ($(date "+%Y-%m-%d"))\n\n"

if [[ ${#features[@]} -gt 0 ]]; then
  newChangelog+="## Features\n${features[*]}\n\n"
fi

if [[ ${#chores[@]} -gt 0 ]]; then
  newChangelog+="## Chores\n${chores[*]}\n\n"
fi

# prepend new changelog to existing one
echo -e "$newChangelog$currentChangelog" > ./CHANGELOG.md

# update package.json
echo "{\"version\": \"$newVersion\"}" | jq . > ./package.json

# create a new commit, tag and push changes
git add .
git commit -m "chore: Bump to version $newVersion"
git tag -a -m "Tag for version $newVersion" "version$newVersion"
git push origin master --tags
