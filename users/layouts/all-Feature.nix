# /etc/nixos/users/layouts/all-Feature.nix
{ config, pkgs, lib, ... }:

let
  # Centralized shortcut catalog.
  shortcutCatalog = import ../../conf/shortcuts.list.nix;

  # Package pure bash scripts into executables dynamically
  pickColorScript = pkgs.writeShellScriptBin "pick_color.sh" (builtins.readFile ../../scripts/pick_color.sh);
  copyGitToken = pkgs.writeShellScriptBin "copyGitToken" (builtins.readFile ../../scripts/copy_git_token.sh);

  # Kathara package
    kathara = pkgs.python3Packages.buildPythonApplication rec {
    pname = "kathara";
    version = "3.8.3";
    format = "setuptools";
    
    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "84a2d3f8ea326cc1128e0a82f13019ed98d18155f8967824e72dc92e295eef84";
    };
    
    doCheck = false;
    
    propagatedBuildInputs = with pkgs.python3Packages; [
      docker
      packaging
      requests
      pyyaml
      python-dateutil
      rich
      binaryornot
      fs
      kubernetes
    ];

    # Expose main script to bin directory to trigger native Nix wrapper
    postInstall = ''
      mkdir -p $out/bin
      cp $out/lib/python${pkgs.python3.pythonVersion}/site-packages/kathara.py $out/bin/kathara
      chmod +x $out/bin/kathara
    '';
  };

  # Environment setup scripts
  setupDb = pkgs.writeShellScriptBin "setup-db" (builtins.readFile ../../scripts/setup_db.sh);
  setupJava = pkgs.writeShellScriptBin "setup-java" (builtins.readFile ../../scripts/setup_java.sh);
  setupMinecraft = pkgs.writeShellScriptBin "setup-minecraft" (builtins.readFile ../../scripts/setup_minecraft.sh);

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

    # Java Development Base
    pkgs.jdk21
    pkgs.eclipses.eclipse-java
    pkgs.scenebuilder

    # Java plugins
    pkgs.plantuml
    pkgs.graphviz
    pkgs.sonar-scanner-cli

    # Network emulation tool
    kathara
    
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
    
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
  };

  xdg.configFile."kitty/kitty.conf".source = ../../conf/kitty.conf;
}
