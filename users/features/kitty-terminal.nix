# /etc/nixos/users/features/kitty-terminal.nix
{ pkgs, lib, ... }:

{
  # Enable Kitty natively to allow automatic integration with the Catppuccin module
  programs.kitty = {
    enable = true;
    # Import base configuration and custom shortcuts (colors are managed by Catppuccin)
    extraConfig = builtins.readFile ../../conf/kitty/kitty.conf;
  };

  # Install related terminal utilities and custom scripts
  home.packages = [
    pkgs.fastfetch
    (pkgs.writeShellScriptBin "set_opacity" (builtins.readFile ../../scripts/set_opacity.sh))
  ];

  # Initialize terminal utilities on shell startup
  programs.zsh.initContent = ''
    fastfetch -c ~/.config/fastfetch/config.jsonc
  '';

  # Deploy configuration files as symbolic links to ~/.config/
  xdg.configFile = {
    "fastfetch/cat-logo.txt".source = ../../conf/fastfetch/cat-logo.txt;
    "fastfetch/config.jsonc".source = ../../conf/fastfetch/fastfetch.jsonc;
  };

  # Initialize dynamic state files to prevent startup errors on first launch
  home.activation.initKittyState = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -f "$HOME/.config/kitty/opacity-state.conf" ]
    then
      $DRY_RUN_CMD mkdir -p "$HOME/.config/kitty"
      $DRY_RUN_CMD echo "background_opacity 1.0" > "$HOME/.config/kitty/opacity-state.conf"
    fi
  '';
}
