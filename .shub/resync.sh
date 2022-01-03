#!/bin/bash

# DevOntheRun Resync Script

.shub/shub-logo.sh
source .shub/colors.sh

echo -e "${GREEN}"
echo "#############################################"
echo "               DOTR RESYNC                   "
echo -e "#############################################${NC}"

# Detect if there is a tag with interation number, and if so, ask user if they want to deploy using that tag info
GIT_BRANCH=$(git branch --show-current)
NEWEST_TAG=$(git describe --abbrev=0 --tags)
arrIN=(${NEWEST_TAG//-/ })
CLASS_TYPE_DETECTED=${arrIN[0]}
NUM=${arrIN[1]}
GIT_BRANCH_FROM_TAG="$CLASS_TYPE_DETECTED-$NUM"

if [[ $NUM =~ ^[0-9]+$ ]] && [ "$GIT_BRANCH_FROM_TAG" != "$GIT_BRANCH" ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Interation number \"$NUM\" of \"$CLASS_TYPE_DETECTED\" was detected from the last tag!${NC}"
    NUM=$((NUM + 1))
    GIT_BRANCH_FROM_NEXT_TAG="$CLASS_TYPE_DETECTED-$NUM"
    read -r -p "Do you want to use it to set your branch as \"$(echo -e $GREEN"$CLASS_TYPE_DETECTED-$NUM"$NC)\" [$(echo -e $GREEN"Y"$NC)/n]? " response
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # tolower
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        git checkout -b $GIT_BRANCH_FROM_NEXT_TAG
        echo -e "${GREEN}✅  Branch set to \"$GIT_BRANCH_FROM_NEXT_TAG\"${NC}"
        GIT_BRANCH_NEXT_CLASS_UP=$(echo "$GIT_BRANCH_FROM_NEXT_TAG" | tr '[:lower:]' '[:upper:]')  # toupper
        echo "## $GIT_BRANCH_NEXT_CLASS_UP" >> notes.md
        echo "" >> notes.md
    fi
else
  echo -e "${YELLOW}⚠️  No interation number detected!${NC}"
fi
