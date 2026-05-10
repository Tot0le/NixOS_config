# /etc/nixos/users/layouts/all-Feature.nix
{ config, pkgs, lib, ... }:

let
  # Centralized shortcut catalog.
  shortcutCatalog = import ../../conf/shortcuts.list.nix;

  # Package pure bash scripts into executables dynamically
  pickColorScript = pkgs.writeShellScriptBin "pick_color.sh" (builtins.readFile ../../scripts/pick_color.sh);
  copyGitToken = pkgs.writeShellScriptBin "copyGitToken" (builtins.readFile ../../scripts/copy_git_token.sh);

  # Environment setup scripts
  setupDb = pkgs.writeShellScriptBin "setup-db" (builtins.readFile ../../scripts/setup_db.sh);
  setupJava = pkgs.writeShellScriptBin "setup-java" (builtins.readFile ../../scripts/setup_java.sh);
  setupMinecraft = pkgs.writeShellScriptBin "setup-minecraft" (builtins.readFile ../../scripts/setup_minecraft.sh);

in
{
  # Inherit base configuration from simple.nix.
  imports = [
    ./simple.nix
    ../../users/features/kathara.nix
    ../../users/features/gnome-custom.nix
  ];

  # Force override the JSON file with the comprehensive shortcut list.
  xdg.configFile."shortcuts-base.json".text = lib.mkForce (builtins.toJSON (
    shortcutCatalog.commonApps // 
    shortcutCatalog.adminApps // 
    shortcutCatalog.graphicTools // 
    shortcutCatalog.fans
  ));

  # Allow unfree packages specifically for Home Manager sessions
  nixpkgs.config.allowUnfree = true;
  
  home.packages = [
    # Kitty terminal
    pkgs.kitty

    # Text editor
    pkgs.vscode

    # Productivity apps
    pkgs.obsidian
    pkgs.pinta
    
    pkgs.fastfetch
    
    # Java Development Base
    pkgs.jdk21
    pkgs.eclipses.eclipse-java
    pkgs.scenebuilder

    # Java plugins
    pkgs.plantuml
    pkgs.graphviz
    pkgs.sonar-scanner-cli
    
    # Environment Setups
    setupDb
    setupJava
    setupMinecraft
    
    # Add private token script.
    copyGitToken

    # Direct import of pick_color script bypassing global modules.
    pickColorScript
  ];

  # Enable and configure Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Execute fastfetch with custom Catppuccin configuration
    initContent = ''
      fastfetch -c ~/.config/fastfetch/config.jsonc
    '';

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
  };

  # Note: Ensure /etc/nixos is owned by the user (sudo chown -R $USER:users /etc/nixos) for Git status.
  xdg.configFile."kitty/kitty.conf".source = ../../conf/kitty.conf;
  xdg.configFile."kitty/kitty-catppuccin-mocha.conf".source = ../../conf/kitty-catppuccin-mocha.conf;
  xdg.configFile."fastfetch/cat-logo.txt".source = ../../conf/cat-logo.txt;
  xdg.configFile."fastfetch/config.jsonc".source = ../../conf/fastfetch.jsonc;
}
