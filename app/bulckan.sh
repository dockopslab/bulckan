#!/bin/bash

# Environment variables
GITHUB_URL=${GITHUB_URL}
GITHUB_BRANCH=${GITHUB_BRANCH:-main}
GITHUB_PATH=${GITHUB_PATH}
CHECK_INTERVAL=${CHECK_INTERVAL:-300}
GITHUB_USERNAME=${GITHUB_USERNAME}
GITHUB_TOKEN=${GITHUB_TOKEN}
RECORD_DIR=${RECORD_DIR:-/record} # Directory to store records

# Initial 5-second pause
echo "Starting in 5 seconds..."
sleep 5

# Ensure the record directory exists
mkdir -p "$RECORD_DIR"
UPDATE_COUNT_FILE="$RECORD_DIR/update_count"
LAST_COMMIT_FILE="$RECORD_DIR/last_commit"
NAME_FILE="$RECORD_DIR/last_name"

# Initialize the record files if they don't exist
if [ ! -f "$UPDATE_COUNT_FILE" ]; then
    echo "1" > "$UPDATE_COUNT_FILE"  # Start with 1 instead of 0
fi

if [ ! -f "$LAST_COMMIT_FILE" ]; then
    echo "none" > "$LAST_COMMIT_FILE"
fi

if [ ! -f "$NAME_FILE" ]; then
    echo "none" > "$NAME_FILE"
fi

# Function to clone or update the repository
clone_or_update_repo() {
    if [ ! -d "repo/.git" ]; then
        echo "Cloning repository..."
        rm -rf repo # Ensure any existing 'repo' directory is removed
        git clone --branch "$GITHUB_BRANCH" "https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@${GITHUB_URL}" repo
        local commit_hash=$(git -C repo rev-parse HEAD)
        record_update "$commit_hash"
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
                record_update "$REMOTE_COMMIT"
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

# Function to record the update
record_update() {
    local commit_hash=$1
    echo "Recording update..."
    
    # Increment the update count
    if [ "$(cat "$UPDATE_COUNT_FILE")" == "1" ] && [ "$(cat "$LAST_COMMIT_FILE")" == "none" ]; then
        echo "1" > "$UPDATE_COUNT_FILE"
    else
        update_count=$(<"$UPDATE_COUNT_FILE")
        update_count=$((update_count + 1))
        echo "$update_count" > "$UPDATE_COUNT_FILE"
    fi
    
    # Save the last deployed commit hash
    echo "$commit_hash" > "$LAST_COMMIT_FILE"
    
    # Extract and save the 'name' from docker-compose.yml
    local name_value=$(grep 'name:' "repo/$GITHUB_PATH/docker-compose.yml" | awk '{print $2}')
    echo "$name_value" > "$NAME_FILE"
}

# Function to extract the 'name' from docker-compose.yml
get_name_value() {
    local name_value=$(grep 'name:' "repo/$GITHUB_PATH/docker-compose.yml" | awk '{print $2}')
    if [ -n "$name_value" ]; then
        echo "$name_value"
    else
        echo "none"
    fi
}

# Function to deploy with docker-compose
deploy() {
    echo "Deploying with docker-compose..."
    
    # Always extract and show the name, even if not redeployed
    local name_value=$(get_name_value)
    echo "$name_value" > "$NAME_FILE"
    
    # Load the update count and last commit into variables
    local update_count=$(<"$UPDATE_COUNT_FILE")
    local last_commit=$(<"$LAST_COMMIT_FILE")
    
    # Export these variables for use in docker-compose.yml
    export UPDATE_COUNT="$update_count"
    export LAST_COMMIT="$last_commit"
    
    # Show the current update count, last deployed commit hash, and name
    echo "Compose name: $(<"$NAME_FILE")"
    echo "Commit deployed: $LAST_COMMIT"
    echo "Total updates: $UPDATE_COUNT"

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
