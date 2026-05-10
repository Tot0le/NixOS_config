#!/bin/bash

# Target flavor from argument
flavor=$1
# Path to the current theme symlink
themeLink="$HOME/.config/kitty/theme.conf"
# Path to the available themes
themeDir="$HOME/.config/kitty/themes"

# Function to update the theme
updateTheme() 
{
    local targetFlavor=$1
    if [ -f "$themeDir/catppuccin-$targetFlavor.conf" ]
    then
        ln -sf "$themeDir/catppuccin-$targetFlavor.conf" "$themeLink"
        # Signal all running kitty instances to reload config
        kill -SIGUSR1 $(pgrep kitty) 2>/dev/null
        echo "Switched to $targetFlavor"
    fi
}

# Auto-detect logic if no argument is provided
if [ -z "$flavor" ]
then
    # Read GNOME color scheme preference
    currentMode=$(dconf read /org/gnome/desktop/interface/color-scheme)
    
    if [ "$currentMode" == "'prefer-dark'" ]
    then
        updateTheme "mocha"
    else
        updateTheme "latte"
    fi
else
    updateTheme "$flavor"
fi
