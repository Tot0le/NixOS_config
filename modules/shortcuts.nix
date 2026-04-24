{ pkgs, ... }:

{
  # Enable dconf for settings management
  programs.dconf.enable = true;

  # Service to initialize shortcuts at login
  systemd.user.services.init-gnome-shortcuts = {
    description = "Initialize GNOME custom shortcuts";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.writeShellScript "init-shortcuts" ''
        DCONF="${pkgs.dconf}/bin/dconf"
        PATH_BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
        
        # Register master list of custom bindings
        $DCONF write $PATH_BASE "['$PATH_BASE/custom-term/', '$PATH_BASE/browser-launch/', '$PATH_BASE/file-manager-launch/', '$PATH_BASE/custom-picker/', '$PATH_BASE/fan-m2/', '$PATH_BASE/fan-p2/', '$PATH_BASE/fan-m10/', '$PATH_BASE/fan-p10/', '$PATH_BASE/fan-50/', '$PATH_BASE/fan-80/', '$PATH_BASE/fan-100/']"

        # Utility to write shortcuts concisely
        set_shortcut() {
            $DCONF write "$PATH_BASE/$1/name" "'$2'"
            $DCONF write "$PATH_BASE/$1/command" "'$3'"
            $DCONF write "$PATH_BASE/$1/binding" "'$4'"
        }

        # Applications
        set_shortcut "custom-term" "Terminal" "kitty" "<Super>c"
        set_shortcut "browser-launch" "Browser" "firefox" "<Super>f"
        set_shortcut "file-manager-launch" "Explorer" "nautilus" "<Super>e"
        set_shortcut "custom-picker" "Picker" "pick_color.sh" "<Super>ugrave"

        # Fan controls
        set_shortcut "fan-m2" "Fan -2%" "fan_control.sh minus 2" "<Super>F1"
        set_shortcut "fan-p2" "Fan +2%" "fan_control.sh plus 2" "<Super>F2"
        set_shortcut "fan-m10" "Fan -10%" "fan_control.sh minus 10" "<Super>F3"
        set_shortcut "fan-p10" "Fan +10%" "fan_control.sh plus 10" "<Super>F4"
        set_shortcut "fan-50" "Fan 50%" "fan_control.sh set 50" "<Super>F5"
        set_shortcut "fan-80" "Fan 80%" "fan_control.sh set 80" "<Super>F6"
        set_shortcut "fan-100" "Fan 100%" "fan_control.sh set 100" "<Super>F7"
      ''}";
    };
  };
}
