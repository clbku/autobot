#!/bin/bash

branch_name=$(git symbolic-ref --short HEAD)
retcode=$?
non_push_suffix="_local"

# get latest tag and commit messages
latestTag=$(git describe --long | awk -F"-" '{print $1}')
output=$(git log ${latestTag}..HEAD --format=%B%H----DELIMITER----)

# # split commits by delimiter and format them
IFS=$'\n'
commitsArray=($(echo "$output" | sed 's/----DELIMITER----//g'))
features=()
chores=()
fixes=()

for commit in "${commitsArray[@]}"; do
  message=$(echo "$commit" | head -1)
  sha=$(echo "$commit" | tail -1)

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

echo $currentChangelog

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

# create a new commit, tag and push changes
if [ $retcode -eq 0 ] ; then
    #Only push if branch_name does not end with the non-push suffix
    if [[ $branch_name != *$non_push_suffix ]] ; then
        echo
        echo "**** Commit changes $branch_name"
        echo
        git add -A;
        git commit -m "chore: Bump to version $newVersion"
        git tag -a -m "Tag for version $newVersion" "version$newVersion"       
        echo "Tagged with $NEW_TAG"
        git push --tags
        echo
        echo "**** Pushing current branch $branch_name to origin [i4h post-commit hook]"
        echo
        git push origin $branch_name;
    fi
fi
