#!/bin/bash

declare -r templatePath="/etc/nixos/templates/postgres-kit.nix"

# Copy template if missing
if [ ! -f "shell.nix" ]
then
    cp "$templatePath" ./shell.nix
    echo "PostgreSQL template copied to current directory."
fi

# Open editor for manual adjustments
nano shell.nix

# Initialize isolated environment
nix-shell
