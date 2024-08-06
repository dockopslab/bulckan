#!/bin/bash

# Environment variables
GITHUB_URL=${GITHUB_URL}
GITHUB_BRANCH=${GITHUB_BRANCH:-main}
GITHUB_PATH=${GITHUB_PATH}
CHECK_INTERVAL=${CHECK_INTERVAL:-300}
GITHUB_USERNAME=${GITHUB_USERNAME}
GITHUB_TOKEN=${GITHUB_TOKEN}

# Initial 5-second pause
echo "Starting in 5 seconds..."
sleep 5

# Function to clone or update the repository
clone_or_update_repo() {
    if [ ! -d "repo/.git" ]; then
        echo "Cloning repository..."
        rm -rf repo # Ensure any existing 'repo' directory is removed
        git clone --branch "$GITHUB_BRANCH" "https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@${GITHUB_URL}" repo
        return 0
    else
        echo "Updating repository..."
        cd "repo"
        git fetch origin "$GITHUB_BRANCH"
        LOCAL_COMMIT=$(git rev-parse "$GITHUB_BRANCH")
        REMOTE_COMMIT=$(git rev-parse "origin/$GITHUB_BRANCH")
        if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
            if git diff --name-only "$LOCAL_COMMIT" "$REMOTE_COMMIT" | grep "^$GITHUB_PATH"; then
                git pull origin "$GITHUB_BRANCH"
                cd ..
                return 0
            else
                echo "No relevant changes detected in the specified path."
                git reset --hard origin/"$GITHUB_BRANCH" # Ensure local branch is up to date
                cd ..
                return 1
            fi
        else
            echo "No changes detected in the repository."
            cd ..
            return 1
        fi
    fi
}

# Function to deploy with docker-compose
deploy() {
    echo "Deploying with docker-compose..."
    cd "repo/$GITHUB_PATH" && docker-compose up -d --build
    cd ../..
}

# Infinite loop to periodically check for changes
while true; do
    clone_or_update_repo
    deploy
    echo "Sleeping for $CHECK_INTERVAL seconds..."
    sleep "$CHECK_INTERVAL"
done
