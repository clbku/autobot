#!/usr/bin/env bash

branch_name=$(git symbolic-ref --short HEAD)
retcode=$?
non_push_suffix="_local"

uncommitted=$(git status -s)

if [[ "$uncommitted" != "" ]]; then
    echo "Need commit first"
    exit
fi

# generate change log
sh ././autobot/changelog.sh

# Only push if branch_name was found (my be empty if in detached head state)
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
f