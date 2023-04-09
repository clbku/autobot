#!/usr/bin/env bash

branch_name=$(git symbolic-ref --short HEAD)
retcode=$?
non_push_suffix="_local"

uncommitted=$(git diff)

if [[ "$uncommitted" == "" ]]; then
    echo "a"
fi

