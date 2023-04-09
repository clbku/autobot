#!/usr/bin/env bash

branch_name=$(git symbolic-ref --short HEAD)
retcode=$?
non_push_suffix="_local"

NEW_TAG="v0.0.1"

# Only push if branch_name was found (my be empty if in detached head state)
if [ $retcode -eq 0 ] ; then
    #Only push if branch_name does not end with the non-push suffix
    if [[ $branch_name != *$non_push_suffix ]] ; then
        echo
        echo "**** Commit changes $branch_name"
        echo
        git add -A;
        git commit -m "build: v0.0.0";
        git tag $NEW_TAG
        echo "Tagged with $NEW_TAG"
        git push --tags
        echo
        echo "**** Pushing current branch $branch_name to origin [i4h post-commit hook]"
        echo
        git push origin $branch_name;
    fi
fi
