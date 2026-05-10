# /etc/nixos/users/features/kitty-terminal.nix
{ pkgs, lib, ... }:

{
  # Core terminal and system information packages
  home.packages = [
    pkgs.kitty
    pkgs.fastfetch
    # Script to manually switch themes
    (pkgs.writeShellScriptBin "switch_theme" (builtins.readFile ../../scripts/switch_theme.sh))
    # Script to set and save opacity state
    (pkgs.writeShellScriptBin "set_opacity" (builtins.readFile ../../scripts/set_opacity.sh))
  ];

  # Execute fastfetch with a custom configuration file on Zsh initialization
  programs.zsh.initContent = ''
    fastfetch -c ~/.config/fastfetch/config.jsonc
    
    # Autocompletion for switch_theme command (ordered from darkest to lightest)
    compdef 'compadd -V flavors mocha macchiato frappe latte' switch_theme
  '';

  # Deploy configuration files as symbolic links to ~/.config/
  xdg.configFile = {
    "kitty/kitty.conf".source = ../../conf/kitty/kitty.conf;
    
    # Store all flavors in a subfolder for the switcher
    "kitty/themes/catppuccin-mocha.conf".source = ../../conf/kitty/catppuccin-mocha.conf;
    "kitty/themes/catppuccin-latte.conf".source = ../../conf/kitty/catppuccin-latte.conf;
    "kitty/themes/catppuccin-frappe.conf".source = ../../conf/kitty/catppuccin-frappe.conf;
    "kitty/themes/catppuccin-macchiato.conf".source = ../../conf/kitty/catppuccin-macchiato.conf;

    "fastfetch/cat-logo.txt".source = ../../conf/fastfetch/cat-logo.txt;
    "fastfetch/config.jsonc".source = ../../conf/fastfetch/fastfetch.jsonc;
  };

  # Initialize the dynamic state files to prevent startup errors on first launch
  home.activation.initKittyState = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -f "$HOME/.config/kitty/opacity-state.conf" ]
    then
      $DRY_RUN_CMD mkdir -p "$HOME/.config/kitty"
      $DRY_RUN_CMD echo "background_opacity 1.0" > "$HOME/.config/kitty/opacity-state.conf"
    fi
    if [ ! -f "$HOME/.config/kitty/theme.conf" ]
    then
      $DRY_RUN_CMD ln -sf "$HOME/.config/kitty/themes/catppuccin-mocha.conf" "$HOME/.config/kitty/theme.conf"
    fi
  '';


  # Note: Ensure /etc/nixos is owned by the user (sudo chown -R $USER:users /etc/nixos) for proper Git status detection.
  
  # Background service to sync Kitty with GNOME theme changes
  systemd.user.services.kitty-theme-sync = {
    Unit = { Description = "Sync Kitty theme with GNOME color-scheme"; };
    Install = { WantedBy = [ "graphical-session.target" ]; };
    Service = {
      ExecStart = "${pkgs.writeShellScript "kitty-sync-daemon" ''
        # Initial sync
        ${pkgs.bash}/bin/bash switch_theme
        # Watch for dconf changes
        ${pkgs.dconf}/bin/dconf watch /org/gnome/desktop/interface/color-scheme | while read -r line; do
          ${pkgs.bash}/bin/bash switch_theme
        done
      ''}";
    };
  };
}
