{ pkgs, ... }:

let
  # Use .r. to place it on the right side, near system tray
  sysMonitoringScript = pkgs.writeShellScriptBin "sysmon.r.2s.sh" ''
    #!/bin/bash
    
    declare -i cpuTempRaw=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0)
    declare -i cpuTemp=$((cpuTempRaw / 1000))
    declare stateFile="/tmp/fan_speed_memory_$(whoami)"
    declare output=""

    # Process CPU temperature
    if [ $cpuTemp -gt 0 ]
    then
        output="CPU: $cpuTemp°C"
    fi

    # Process Fan speed
    if [ -f "$stateFile" ]
    then
        declare -i currentSpeed=$(cat "$stateFile")
        if [ -n "$output" ]
        then
            output="$output | Fan: $currentSpeed%"
        else
            output="Fan: $currentSpeed%"
        fi
    fi

    # Print only if there is data to display
    if [ -n "$output" ]
    then
        echo "$output"
    else
        echo "Fan: Auto"
    fi
  '';
in
{
  environment.systemPackages = with pkgs; [
    gnomeExtensions.argos
    sysMonitoringScript
  ];

  systemd.user.services.init-gnome-monitoring = {
    description = "Initialize custom Argos monitoring";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.writeShellScript "init-argos" ''
        # Enable Argos extension
        ${pkgs.gnome-shell}/bin/gnome-extensions enable argos@pew.worldwidemann.com

        declare argosDir="$HOME/.config/argos"
        mkdir -p "$argosDir"
        
        # Clean old scripts to remove duplicates and ghost texts
        rm -f "$argosDir"/*
        
        # Link the correct new script
        ln -sf ${sysMonitoringScript}/bin/sysmon.r.2s.sh "$argosDir/sysmon.r.2s.sh"
      ''}";
    };
  };
}
