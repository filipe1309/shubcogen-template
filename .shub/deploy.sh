#!/bin/bash

# DevOntheRun Deploy Script

.shub/shub-logo.sh
source .shub/colors.sh
source .shub/helpers.sh
source .shub/.shub-envs.sh

read_arguments $*

VERSION=$(head -n 1 .shub/version)
STATE="0"

echo -e "${GREEN}"
echo "#############################################"
echo "               DOTR DEPLOY $VERSION                   "
echo -e "#############################################${NC}"
echo ""

.shub/self-update.sh && exit 0

if [ -f ".shub-state.ini" ]; then
    source .shub-state.ini
    source .shub-state-variables.ini
    echo -e "${YELLOW}⚠️  State file founded!${NC}"
  
    read -r -p "Do you want to use state file at step $(echo -e $GREEN"$STATE"$NC) [$(echo -e $GREEN"Y"$NC)/n]? " response
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # tolower
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        echo -e "👉 State setted to \"${GREEN}$STATE${NC}\"."
    else
        STATE="0"
        flush_state
    fi
fi


if test $STATE -lt 1; then
    save_state_var "FAILED_MSG" "$FAILED_MSG"
    save_state_var "GIT_BRANCH" "$GIT_BRANCH"
    save_state_var "GIT_BRANCH_NEXT_CLASS" "$GIT_BRANCH_NEXT_CLASS"
    save_state_var "GIT_BRANCH_NEXT_CLASS_LW" "$GIT_BRANCH_NEXT_CLASS_LW"
    save_state_var "GIT_BRANCH_NEXT_CLASS_UP" "$GIT_BRANCH_NEXT_CLASS_UP"
fi

echo -e "⬇ Branch to deploy: \"${GREEN}$GIT_BRANCH${NC}\""

# Check if branch is master/main
MAIN_BRANCHES=("master" "main")
if array_contains MAIN_BRANCHES "$GIT_BRANCH"; then
    echo  -e "${YELLOW}⚠️  You are commiting to the $GIT_BRANCH branch, and this deploy script is not designed to deploy to the $GIT_BRANCH branch.${NC}"
    confirm "$(echo -e $YELLOW"Are you sure you want to continue?"$NC) [$(echo -e $GREEN"Y"$NC)/n]? "
fi

echo -e "⏩ Next branch: \"${GREEN}$GIT_BRANCH_NEXT_CLASS_LW${NC}\""

echo "---------------------------------------------"

#################
#### TAGGING ####
#################

generateTag() {
    if [[ $NEWEST_TAG != *$GIT_BRANCH* ]]; then
        if [ -z "$ALL" ]; then
            read -r -p "Do you want to generate a $(echo -e $GREEN"tag"$NC) based on branch \"$(echo -e $GREEN"$GIT_BRANCH"$NC)\" [$(echo -e $GREEN"Y"$NC)/n]? " response
            response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # tolower
        else
            response="y"
        fi
        if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
            echo ""
            echo -e "🏷  ${GREEN}Generating tag...${NC}"
            echo ""
            echo "# TAG MESSAGE"
            echo -e "# Example: ${GREEN}\"$(git tag -n9 | head -n 1 | awk '{for(i=2;i<=NF;++i)printf $i FS}')\"${NC}"
            TAG_MSG_PREFIX_SUGGESTION="$(tr '[:lower:]' '[:upper:]' <<< ${TAG_NAME:0:1})${TAG_NAME:1}"
            
            save_state_var "TAG_MSG_PREFIX_SUGGESTION" "$TAG_MSG_PREFIX_SUGGESTION"
            
            if [ -z "$ALL" ]; then
                echo -e "Type the tag message prefix [${GREEN}$TAG_MSG_PREFIX_SUGGESTION - ${NC}]:"
                read -e TAG_MSG_PREFIX
            fi

            save_state_var "TAG_MSG_PREFIX" "$TAG_MSG_PREFIX"

            if [ -z "$TAG_MSG_PREFIX"  -a "$TAG_MSG_PREFIX" != " " ]; then
                TAG_MSG_PREFIX=$TAG_MSG_PREFIX_SUGGESTION
            fi

            if [ -z "$ALL" ] && [ -z "$MESSAGE" ]; then
                echo -e "Type the tag message [${GREEN}$TAG_MSG${NC}]:"
                read -e TAG_MSG_USR
            fi
            if [ ! -z "$MESSAGE"  -a "$MESSAGE" != " " ]; then
                TAG_MSG_USR="$MESSAGE"
            fi

            save_state_var "TAG_MSG_USR" "$TAG_MSG_USR"

            if [ ! -z "$TAG_MSG_USR"  -a "$TAG_MSG_USR" != " " ]; then
                TAG_MSG_SLUG=$(echo "$TAG_MSG_USR" | iconv -t ascii//TRANSLIT | sed -r 's/[~\^]+//g' | sed -r 's/[^a-zA-Z0-9]+/-/g' | sed -r 's/^-+\|-+$//g' | tr A-Z a-z)
                TAG_NAME="${TAG_NAME}-${TAG_MSG_SLUG}"
                TAG_MSG="$TAG_MSG_PREFIX - $TAG_MSG_USR"
            fi
            
            echo ""
            echo "---------------------------------------------"
            echo -e "[NAME]= \"${GREEN}$TAG_NAME${NC}\""
            echo -e "[MSG]= \"${GREEN}$TAG_MSG${NC}\""
            echo "---------------------------------------------"
            
            save_state_var "TAG_NAME" "$TAG_NAME"
            save_state_var "TAG_MSG" "$TAG_MSG"

            if [ -z "$ALL" ]; then
                read -r -p "Are you sure [$(echo -e $GREEN"Y"$NC)/n]? " response
                response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # tolower
                echo ""
            else
                response="y"
            fi
            
            if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
                git tag -a $TAG_NAME -m "$TAG_MSG"                
                echo ""
                echo -e "🏷  ${GREEN}Tag ($TAG_NAME) generated!${NC}"
            else
                read -r -p "Recreate tag [$(echo -e $GREEN"Y"$NC)/n]? " response
                response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # tolower
                if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
                    generateTag
                fi
                echo "Bye =)"
                exit 0
            fi
        fi
    fi
}



#################
#### BRANCH #####
#################

# STEP 1 - SHUB FILES

if test $STATE -lt 1; then
    echo ""
    echo "🏁 Starting deploy process ..."
    echo "✔ Auto commiting notes ..."
    git add notes.md && git commit -m "docs: update notes"
    if ( ! test -f ".gitignore" ) || ( test -f ".gitignore" && ! grep -q .shub ".gitignore" ); then
        echo "✔ Auto commiting shub files ..."
        git add .shub && git commit -m "chore: update shub files"  
    fi
    commit_state "1"
fi

# STEP 2 - CHECKOUT

if test $STATE -lt 2; then
    echo "---------------------------------------------"
    echo ""
    if [ -z "$ALL" ]; then
        confirm "Checkout to \"$(echo -e $GREEN"$GIT_DEFAULT_BRANCH"$NC)\" branch [$(echo -e $GREEN"Y"$NC)/n]? "
    fi
    { git checkout $GIT_DEFAULT_BRANCH  || { echo -e "$FAILED_MSG" ; exit 1; } }
    commit_state "2"
    echo ""
fi

# STEP 3 - MERGE

if test $STATE -lt 3; then
    echo "---------------------------------------------"
    echo ""
    if [ -z "$ALL" ]; then
        confirm "Merge current branch ($GIT_BRANCH) [$(echo -e $GREEN"Y"$NC)/n]? "
    fi
    { git merge $GIT_BRANCH  || { echo -e "$FAILED_MSG" ; exit 1; } }
    commit_state "3"
    echo ""
fi

# STEP 4 - TAG

if test $STATE -lt 4; then
    echo "---------------------------------------------"
    echo ""
    generateTag
    commit_state "4"
    echo ""
fi

# STEP 5 - DEPLOY BRANCH

if test $STATE -lt 5; then
    if [ -z "$ALL" ]; then
        confirm "Deploy on \"$(echo -e $GREEN"$GIT_DEFAULT_BRANCH"$NC)\" branch [$(echo -e $GREEN"Y"$NC)/n]? "
    fi
    echo ""
    echo "🚀 Deploying on \"$(echo -e $GREEN"$GIT_DEFAULT_BRANCH"$NC)\" branch"
    { git push origin $GIT_DEFAULT_BRANCH  || { echo -e "$FAILED_MSG" ; exit 1; } }
    commit_state "5"
fi

# STEP 6 - DEPLOY TAG

echo ""
if test $STATE -lt 6; then
    if [ -z "$ALL" ]; then
        confirm "Deploy tag \"$(echo -e $GREEN"$TAG_NAME"$NC)\" [$(echo -e $GREEN"Y"$NC)/n]? "
    fi
    echo ""
    { git push origin $GIT_DEFAULT_BRANCH --tags  || { echo -e "$FAILED_MSG" ; exit 1; } }
    commit_state "6"
    echo ""
    echo -e "${GREEN}"
    echo "#############################################"
    echo "               🏁 DEPLOY COMPLETED                   "
    echo -e "#############################################${NC}"
    echo ""
fi

# STEP 7 - NEXT

if test $STATE -lt 7; then
    if [ -z "$ALL" ]; then
        confirm "Go to next \"$(echo -e $GREEN"$COURSE_TYPE"$NC)\" ($GIT_BRANCH_NEXT_CLASS_LW) [$(echo -e $GREEN"Y"$NC)/n]? " 
    fi
    echo ""
    git checkout -b $GIT_BRANCH_NEXT_CLASS_LW
fi

if [ -f ".shub-state.ini" ]; then
    flush_state
fi

# Update notes file
echo ""
echo "## $GIT_BRANCH_NEXT_CLASS_UP" >> notes.md
echo "" >> notes.md
