# /etc/nixos/users/layouts/all-Feature.nix
{ config, pkgs, lib, ... }:

let
  # Centralized shortcut catalog.
  shortcutCatalog = import ../../conf/shortcuts.list.nix;

  # Package pure bash scripts into executables dynamically
  pickColorScript = pkgs.writeShellScriptBin "pick_color.sh" (builtins.readFile ../../scripts/pick_color.sh);
  copyGitToken = pkgs.writeShellScriptBin "copyGitToken" (builtins.readFile ../../scripts/copy_git_token.sh);
in
{
  # Inherit base configuration from simple.nix.
  imports = [ ./simple.nix ];

  # Force override the JSON file with the comprehensive shortcut list.
  xdg.configFile."shortcuts-base.json".text = lib.mkForce (builtins.toJSON (
    shortcutCatalog.commonApps // 
    shortcutCatalog.adminApps // 
    shortcutCatalog.graphicTools // 
    shortcutCatalog.fans
  ));

  home.packages = [
    pkgs.kitty
    # Add private token script.
    copyGitToken
    # Direct import of pick_color script bypassing global modules.
    pickColorScript
  ];

  xdg.configFile."kitty/kitty.conf".source = ../../conf/kitty.conf;
}
