# /etc/nixos/users/layouts/simple.nix
{ config, pkgs, ... }:

let
  # Import the centralized shortcut catalog
  shortcutCatalog = import ../../conf/shortcuts.list.nix;

  # Base shortcuts for every user (Apps + Basic Fans)
  baseShortcuts = shortcutCatalog.commonApps // {
    fanMinus10 = shortcutCatalog.fans.fanMinus10;
    fanPlus10 = shortcutCatalog.fans.fanPlus10;
  };

  # Export base shortcuts to JSON for the python bridge
  baseShortcutsFile = pkgs.writeText "base-shortcuts.json" (builtins.toJSON baseShortcuts);

  # Python script handling GNOME shortcuts sync.
  pythonSyncScript = pkgs.writeScript "convert-shortcuts.py" ''
    import sys
    import configparser
    import json
    import os
    import subprocess
    from typing import Dict, List

    def convertIniToJson() -> None:
        iniConfig: configparser.ConfigParser = configparser.ConfigParser(interpolation=None)
        iniConfig.read_string(sys.stdin.read())
        jsonOutput: Dict[str, List[str]] = {}
        
        for section in iniConfig.sections():
            shortcutName: str = iniConfig[section].get("name", "").strip("'")
            shortcutCommand: str = iniConfig[section].get("command", "").strip("'")
            shortcutBinding: str = iniConfig[section].get("binding", "").strip("'")
            jsonOutput[section] = [shortcutName, shortcutCommand, shortcutBinding]
            
        print(json.dumps(jsonOutput, indent=2))

    def applyJsonToGnome() -> None:
        # Read the generated base shortcuts JSON file.
        basePath: str = "/home/${config.home.username}/.config/shortcuts-base.json"
        with open(basePath, "r") as f:
            mergedShortcuts = json.load(f)
            
        overridePath: str = "/home/${config.home.username}/.config/shortcuts-override.json"
        if os.path.exists(overridePath):
            try:
                with open(overridePath, "r") as f:
                    overrides = json.load(f)
                    for k, v in overrides.items():
                        if len(v) == 3 and v[1] != "":
                            mergedShortcuts[k] = v
            except Exception:
                pass

        pathBase = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
        pathsArray = "[" + ", ".join([f"'{pathBase}/{k}/'" for k in mergedShortcuts.keys()]) + "]"
        subprocess.run(["dconf", "write", pathBase, pathsArray])
            
        for key, data in mergedShortcuts.items():
            path: str = f"{pathBase}/{key}/"
            subprocess.run(["dconf", "write", f"{path}name", f"'{data[0]}'"])
            subprocess.run(["dconf", "write", f"{path}command", f"'{data[1]}'"])
            subprocess.run(["dconf", "write", f"{path}binding", f"'{data[2]}'"])

    if __name__ == "__main__":
        if len(sys.argv) > 1 and sys.argv[1] == "--apply":
            applyJsonToGnome()
        else:
            convertIniToJson()
  '';
in
{
  # Home Manager requires the state version to match the system installation
  home.stateVersion = "25.11";

  # Export base shortcuts to a local JSON file.
  xdg.configFile."shortcuts-base.json".text = builtins.toJSON baseShortcuts;
  
  # Inject Nix syntax highlighting for Micro editor
  xdg.configFile."micro/syntax/nix.yaml".source = ../../conf/micro-nix.yaml;

  # Note: We removed dconf.settings keybindings to let the bridge manage them dynamically

  # Background service to sync GNOME changes back to the JSON file
  systemd.user.services.shortcut-sync-back = {
    Unit = {
      Description = "Sync manual GNOME shortcut changes to local JSON storage";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.writeShellScript "sync-shortcuts" ''
        # 1. First, apply existing overrides from JSON to GNOME
        ${pkgs.python3}/bin/python3 ${pythonSyncScript} --apply

        # Monitor dconf for changes in custom keybindings
        ${pkgs.dconf}/bin/dconf watch /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ | while read -r line
        do
          # Process output with external Python script to avoid bash escaping issues
          ${pkgs.dconf}/bin/dconf dump /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ | ${pkgs.python3}/bin/python3 ${pythonSyncScript} > $HOME/.config/shortcuts-override.json
        done
      ''}";
    };
  };
}
