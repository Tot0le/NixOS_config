#!/bin/bash

# Fetch raw color data via GNOME D-Bus interface.
declare rawData=""
declare hexColor=""

rawData=$(gdbus call --session \
    --dest org.gnome.Shell.Screenshot \
    --object-path /org/gnome/Shell/Screenshot \
    --method org.gnome.Shell.Screenshot.PickColor)
    
if [ -n "$rawData" ]
then
    export RAW_DATA="$rawData"
    
    # Parse and convert raw RGB tuple to Hex format using Python.
    hexColor=$(python3 -c '
import os
import re
def convertToHex() -> str:
    rawInput: str = os.getenv("RAW_DATA", "")
    resultHex: str = ""
    match = re.search(r"\(([\d\.]+),\s*([\d\.]+),\s*([\d\.]+)\)", rawInput)
    if match:
        r: int = int(float(match.group(1)) * 255)
        g: int = int(float(match.group(2)) * 255)
        b: int = int(float(match.group(3)) * 255)
        resultHex = "#{:02x}{:02x}{:02x}".format(r, g, b)
    return resultHex
print(convertToHex())
    ')
    
    if [ -n "$hexColor" ]
    then
        # Copy result to Wayland clipboard and dispatch notification.
        echo -n "$hexColor" | wl-copy
        notify-send "Color Picker" "Copied: $hexColor" -i color-select
    fi
fi
