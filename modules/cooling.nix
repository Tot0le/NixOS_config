# /etc/nixos/modules/cooling.nix
{ pkgs, userList, ... }:

let
  # Define strict absolute paths to match sudo security rules
  nbfcCmd = "${pkgs.nbfc-linux}/bin/nbfc";
  systemctlCmd = "/run/current-system/sw/bin/systemctl";
  
  # Script to control fan speed via NBFC
  fanScript = pkgs.writeShellScriptBin "fan_control.sh" ''
    #!/bin/bash
    declare action="$1"
    declare param="$2"
    declare -i HARD_LIMIT=100
    # One file per user
    declare STATE_FILE="/tmp/fan_speed_memory_$(whoami)"
    declare -i step=''${param:-2}

    if ! systemctl is-active --quiet nbfc_service
    then
        sudo ''${systemctlCmd} restart nbfc_service
        sleep 2
    fi

    declare -i current_speed
    declare -i new_speed

    if [ -f "$STATE_FILE" ]
    then
        current_speed=$(cat "$STATE_FILE")
    else
        current_speed=$(sudo ''${nbfcCmd} status | grep -m1 "Target" | sed 's/.*Target: \([0-9]*\).*/\1/')
        if [ -z "$current_speed" ]
        then 
            current_speed=20
        fi
    fi

    if [ "$action" == "auto" ]
    then
        sudo ''${nbfcCmd} set -a
        rm -f "$STATE_FILE"
    elif [ "$action" == "set" ]
    then
        declare -i target=''${param:-100}
        if [ $target -gt $HARD_LIMIT ]
        then 
            target=$HARD_LIMIT
        fi
        if [ $target -lt 0 ]
        then 
            target=0
        fi
        sudo ''${nbfcCmd} set -s $target
        echo "$target" > "$STATE_FILE"
    elif [ "$action" == "plus" ]
    then
        if [ $current_speed -lt 30 ]
        then
            new_speed=30
        else
            new_speed=$((current_speed + step))
        fi
        if [ $new_speed -gt $HARD_LIMIT ]
        then 
            new_speed=$HARD_LIMIT
        fi
        sudo ''${nbfcCmd} set -s $new_speed
        echo "$new_speed" > "$STATE_FILE"
    elif [ "$action" == "minus" ]
    then
        new_speed=$((current_speed - step))
        if [ $new_speed -lt 0 ]
        then 
            new_speed=0
        fi
        sudo ''${nbfcCmd} set -s $new_speed
        echo "$new_speed" > "$STATE_FILE"
    fi
  '';
in
{
  # Install required packages for cooling
  environment.systemPackages = [
    fanScript
    pkgs.nbfc-linux
  ];

  # Authorize each user in the list for specific fan commands
  security.sudo.extraRules = builtins.map (user: {
    users = [ user ];
    commands = [
      {
        # Permission to restart the fan service
        command = "/run/current-system/sw/bin/systemctl restart nbfc_service";
        options = [ "NOPASSWD" ];
      }
      {
        # Permission to use nbfc directly for speed changes
        command = "${pkgs.nbfc-linux}/bin/nbfc";
        options = [ "NOPASSWD" ];
      }
    ];
  }) userList;
}
