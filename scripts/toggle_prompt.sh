#!/bin/bash

declare stateFile="$HOME/.config/prompt-state"
declare currentState=$(cat "$stateFile" 2>/dev/null)

# Swap the state
if [ "$currentState" == "starship" ]
then
    echo "omz" > "$stateFile"
else
    echo "starship" > "$stateFile"
fi

# Send SIGUSR2 to all running Zsh instances to force a clean reload
kill -SIGUSR2 $(pgrep zsh) 2>/dev/null
