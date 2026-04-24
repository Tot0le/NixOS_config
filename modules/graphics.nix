{ pkgs, ... }:

let
  # Color picker using GNOME service and Python 
  pickerScript = pkgs.writeShellScriptBin "pick_color.sh" ''
    #!/bin/bash
    declare rawData
    declare hexColor

    rawData=$(gdbus call --session \
        --dest org.gnome.Shell.Screenshot \
        --object-path /org/gnome/Shell/Screenshot \
        --method org.gnome.Shell.Screenshot.PickColor)

    if [ -n "$rawData" ]
    then
        export RAW_DATA="$rawData"
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
            echo -n "$hexColor" | ${pkgs.wl-clipboard}/bin/wl-copy
            ${pkgs.libnotify}/bin/notify-send "Color Picker" "Copié : $hexColor" -i color-select
        fi
    fi
  '';
in
{
  # Dependencies for color picking and notifications
  environment.systemPackages = [
    pickerScript
    pkgs.python3
    pkgs.wl-clipboard
    pkgs.libnotify
  ];
}
