# /etc/nixos/conf/shortcuts.list.nix
{
  # Schema: name = [ "Display Name" "Command" "Binding" ];
  apps = {
    terminal = [ "Terminal" "kitty" "<Super>c" ];
    browser  = [ "Browser" "firefox" "<Super>f" ];
    explorer = [ "Explorer" "nautilus" "<Super>e" ];
    picker   = [ "Picker" "pick_color.sh" "<Super>ugrave" ];
  };

  fans = {
    fanMinus2   = [ "Fan -2%" "fan_control.sh minus 2" "<Super>F1" ];
    fanPlus2    = [ "Fan +2%" "fan_control.sh plus 2" "<Super>F2" ];
    fanMinus10  = [ "Fan -10%" "fan_control.sh minus 10" "<Super>F3" ];
    fanPlus10   = [ "Fan +10%" "fan_control.sh plus 10" "<Super>F4" ];
    fanSet50    = [ "Fan 50%" "fan_control.sh set 50" "<Super>F5" ];
    fanSet80    = [ "Fan 80%" "fan_control.sh set 80" "<Super>F6" ];
    fanSet100   = [ "Fan 100%" "fan_control.sh set 100" "<Super>F7" ];
  };
}
