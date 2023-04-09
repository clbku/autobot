#!/bin/bash

# get latest tag and commit messages
latestTag=$(git describe --long | awk -F"-" '{print $1}')
output=$(git log ${latestTag}..HEAD --format=%B%H----DELIMITER----)

# split commits by delimiter and format them
commitsArray=($(echo "$output" | sed 's/----DELIMITER----//g'))
features=()
chores=()
fixes=()

for commit in "${commitsArray[@]}"; do
  message=$(echo "$commit" | head -1)

  if [[ "$message" == feature:* ]]; then
    features+=("* $(echo "$message" | sed 's/^feature: //')")
  fi

  if [[ "$message" == chore:* ]]; then
    chores+=("* $(echo "$message" | sed 's/^chore: //')")
  fi

  if [[ "$message" == fix:* ]]; then
    fixes+=("* $(echo "$message" | sed 's/^chore: //')")
  fi
done

# create new version and changelog
currentChangelog=$(cat ./CHANGELOG.md)
currentVersion=$(node -p "require('./version.json').version")
newVersion=$((currentVersion + 1))
newChangelog="# Version $newVersion ($(date "+%Y-%m-%d"))\n\n"

if [[ ${#features[@]} -gt 0 ]]; then
  newChangelog+="## Features\n${features[*]}\n\n"
fi

if [[ ${#chores[@]} -gt 0 ]]; then
  newChangelog+="## Chores\n${chores[*]}\n\n"
fi

if [[ ${#fixes[@]} -gt 0 ]]; then
  newChangelog+="## Bug fixed\n${fixes[*]}\n\n"
fi

# prepend new changelog to existing one
echo -e "$newChangelog$currentChangelog" > ./CHANGELOG.md

# update package.json
echo "{\"version\": \"$newVersion\"}" > ./version.json