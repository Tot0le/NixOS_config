#!/bin/bash

# Define the path for the dynamic opacity state file
declare stateFile="$HOME/.config/kitty/opacity-state.conf"
declare targetOpacity=$1
declare targetDir=$(dirname "$stateFile")

# Ensure the configuration directory exists
if [ ! -d "$targetDir" ]
then
    mkdir -p "$targetDir"
fi

# Write the updated opacity value
echo "background_opacity $targetOpacity" > "$stateFile"

# Send the reload signal to Kitty instances
kill -SIGUSR1 $(pgrep kitty) 2>/dev/null
