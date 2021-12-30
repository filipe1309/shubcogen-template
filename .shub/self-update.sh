#!/bin/bash

# DevOntheRun Self-Update Script

source .shub/helpers.sh

LOCAL_VERSION=$(head -n 1 .shub/version)

curl -o .shub/latest-release.json --create-dirs https://api.github.com/repos/filipe1309/shubcogen-template/releases/latest
LATEST_RELEASE="$(cat .shub/latest-release.json)"
REMOTE_VERSION=$(parse_json "$LATEST_RELEASE" tag_name)
rm .shub/latest-release.json

if [ "$REMOTE_VERSION" != "$LOCAL_VERSION" ]; then
        read -r -p "There is a new version of ShubCoGen script ($REMOTE_VERSION), do you want to update it? [Y/n] " response
        response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # tolower
        if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
            echo "Updating..."
            curl -o .shub/links.txt --create-dirs https://raw.githubusercontent.com/filipe1309/shubcogen-template/main/.shub/links.txt
            cat .shub/links.txt | while read CMD; do curl -o $(echo ".shub/$(basename $CMD) --create-dirs $CMD"); done;
            chmod -R +x .shub/*.sh
            
            # Update version file
            echo "$REMOTE_VERSION" > .shub/version
        
            if ( ! test -f ".gitignore" ) || ( test -f ".gitignore" && ! grep -q .shub ".gitignore" ); then
                echo "✔ Auto commiting shub files ..."
                git add .shub && git commit -m "chore: update shub files"  
            fi
            
            exit 0
        fi
fi

exit 1
