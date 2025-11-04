#!/bin/bash

# Function to check internet connection
check_internet() {
    if ! ping -c 1 -W 1 google.com &> /dev/null; then
        echo "No internet connection. Aborting."
        exit 1
    fi
}

# Check internet before proceeding
check_internet

# Path to local release-info.json
LOCAL_FILE="/usr/share/HackerOS/Config-Files/release-info.json"

# Download remote version file to /tmp
REMOTE_URL="https://raw.githubusercontent.com/HackerOS-Linux-System/HackerOS-Updates/main/version.hacker"
curl -s -o /tmp/version.hacker "$REMOTE_URL" || { echo "Failed to download remote version file."; exit 1; }

# Extract local version from JSON (assuming jq is installed; if not, use sed/awk alternative)
if command -v jq &> /dev/null; then
    LOCAL_VERSION=$(jq -r '.version' "$LOCAL_FILE" | awk '{print $1}')
else
    LOCAL_VERSION=$(grep '"version"' "$LOCAL_FILE" | sed 's/.*: "\(.*\) ->.*/\1/')
fi

# Extract remote version
REMOTE_VERSION=$(sed 's/^\[\(.*\)\]$/\1/' /tmp/version.hacker)

# Compare versions numerically (using sort -V for version comparison)
if [[ $(echo -e "$LOCAL_VERSION\n$REMOTE_VERSION" | sort -V | tail -n1) != "$LOCAL_VERSION" ]]; then
    # Clone the repo to /tmp
    git clone https://github.com/HackerOS-Linux-System/HackerOS-Updates.git /tmp/HackerOS-Updates || { echo "Failed to clone repository."; exit 1; }
    
    # Give execute permissions to unpack.sh
    sudo chmod a+x /tmp/HackerOS-Updates/unpack.sh
    
    # Run the script
    /tmp/HackerOS-Updates/unpack.sh
else
    # No newer version, do nothing
    :
fi

# Clean up temporary file
rm -f /tmp/version.hacker
