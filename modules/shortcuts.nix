#/etc/nixos/modules/shortcuts.nix
{ pkgs, ... }:

let
  # Import shortcut definitions from the centralized list
  shortcutData = import ../conf/shortcuts.list.nix;
  
  # Merge all categories (apps and fans)
  allShortcuts = shortcutData.apps // shortcutData.fans;
  
  # Configuration for GNOME custom keybindings path
  pathBase = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings";
  
  # Generate the list of dconf paths for the master settings
  bindingPaths = builtins.map (name: "'${pathBase}/${name}/'") (builtins.attrNames allShortcuts);
  
  # Generate dconf write commands for each shortcut entry
  generateDconf = pkgs.lib.mapAttrsToList (name: data: ''
    $DCONF write "${pathBase}/${name}/name" "'${builtins.elemAt data 0}'"
    $DCONF write "${pathBase}/${name}/command" "'${builtins.elemAt data 1}'"
    $DCONF write "${pathBase}/${name}/binding" "'${builtins.elemAt data 2}'"
  '') allShortcuts;

  
  # Generate commands for system-wide overrides
  generateOverrides = pkgs.lib.mapAttrsToList (key: value: ''
    $DCONF write "/org/gnome/settings-daemon/plugins/media-keys/${key}" "${value}"
  '') (shortcutData.systemOverrides or {});
  
in
{
  # Enable dconf for settings management
  programs.dconf.enable = true;

  # Service to initialize shortcuts at login
  systemd.user.services.init-gnome-shortcuts = {
    description = "Initialize GNOME custom shortcuts from centralized list";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.writeShellScript "init-shortcuts" ''
        DCONF="${pkgs.dconf}/bin/dconf"

        # Apply system-wide shortcut overrides
        ${builtins.concatStringsSep "\n" generateOverrides}

        # Register the list of active custom bindings
        $DCONF write ${pathBase} "[${builtins.concatStringsSep ", " bindingPaths}]"

        # Apply each specific shortcut defined in the list
        ${builtins.concatStringsSep "\n" generateDconf}
      ''}";
    };
  };
}
