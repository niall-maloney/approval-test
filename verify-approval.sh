#!/bin/bash

branch=${GITHUB_BASE_REF##*/}

semver_rx='^(.*)(:)([0-9]+\.){2,2}(\*|[0-9]+)(\-.*){0,1}$'

while IFS= read -r line; do
    if ! [[ $(echo $line | awk '/\[-.*:+[0-9]\.+[0-9]\.+[0-9].*-\]{\+.*:+[0-9]\.+[0-9]\.+[0-9].*\+}/') ]]; then
        echo "\"$line\" is not an image change."
        exit 1;
    fi    
    
    current=$(echo $line |  awk -F"[][]" '{print substr($2,2,length($2)-2)}')
    next=$(echo $line | awk -F'[{}]' '{print substr($2,2,length($2)-2)}')

    if [[ ! $current =~ $semver_rx ]]; then
        echo "$current is not an image"
        exit 1;
    fi

    if [[ ! $next =~ $semver_rx ]]; then
        echo "$next is not an image"
        exit 1;
    fi

    if [[ "$(echo $current | awk -F. -v OFS=. '{$NF++;print}')" = $next ]]; then
        echo "$next is one patch increment higher than $current"
    else
        echo "$next is not one patch increment higher than $current"
        exit 1;
    fi
done <<< "$(git diff $branch..HEAD --word-diff | awk '/{+.*+}/ {print}')"