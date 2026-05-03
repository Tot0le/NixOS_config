#!/bin/bash

declare -r templatePath="/etc/nixos/templates/minecraft-kit.nix"

# Copy template if missing
if [ ! -f "shell.nix" ]
then
    cp "$templatePath" ./shell.nix
    echo "Minecraft template copied to current directory."
fi

# Open editor for manual adjustments
nano shell.nix

# Initialize isolated environment
nix-shell
