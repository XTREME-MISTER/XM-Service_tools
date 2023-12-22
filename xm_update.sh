#!/bin/bash

# GitHub repository details
repo_owner="XTREME-MISTER"
repo_name="XM-Service_tools"

# Function to fetch the latest release information
get_latest_release() {
    local api_url="https://api.github.com/repos/$repo_owner/$repo_name/releases/latest"
    local release_info=$(wget -qO- "$api_url")
    echo "$release_info"
}

# Function to download and unzip the latest release
download_and_unzip_release() {
    local release_name=$1
    local zip_url="https://github.com/$repo_owner/$repo_name/releases/download/$release_name/$release_name.zip"

    # Create a temporary directory to download and extract the release
    temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # Download the release zip file
    echo "Downloading release $release_name..."
    wget -qN "$zip_url"

    # Unzip the release
    unzip -q "$release_name.zip"

    rm "$release_name.zip"

    # Move the contents to the script's directory
    mv "$temp_dir"/* "$script_dir"

    # Clean up temporary directory
    rm -rf "$temp_dir"
}


# Get the process ID (PID) of xmsl
pid=$(ps aux | grep '[x]msl' | awk '{print $1}')

# Check if the process is running
if [ -n "$pid" ]; then
    # If it's running, kill the process
    kill "$pid"
    echo "Terminated xmsl process with PID $pid"
fi

# Get the script's directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# Check for the latest release
latest_release=$(get_latest_release)
release_name=$(echo "$latest_release" | jq -r .tag_name)

echo "Last release: $release_name"

if [ "$release_name" != "null" ]; then
    # Check if a new release is available
    if [ ! -f ".last_release" ] || [ "$(cat .last_release)" != "$release_name" ]; then
        # Download and unzip the latest release
        download_and_unzip_release "$release_name"
        
        cd "$script_dir"
        touch .last_release
        # Update the last release file
        echo "$release_name" > .last_release
        
        echo "New release $release_name downloaded and extracted."
    else
        echo "No new release available."
    fi
else
    echo "Error: Unable to fetch release information."
fi

# Restart xmsl
/media/fat/xmsl/xmsl /dev/ttyACM0 &>/dev/null &

echo "End update"

exit 0