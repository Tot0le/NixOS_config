# /etc/nixos/users/features/kitty-terminal.nix
{ pkgs, ... }:

{
  # Core terminal and system information packages
  home.packages = [
    pkgs.kitty
    pkgs.fastfetch
  ];

  # Execute fastfetch with a custom configuration file on Zsh initialization
  programs.zsh.initContent = ''
    fastfetch -c ~/.config/fastfetch/config.jsonc
  '';

  # Deploy configuration files as symbolic links to ~/.config/
  xdg.configFile = {
    "kitty/kitty.conf".source = ../../conf/kitty.conf;
    "kitty/kitty-catppuccin-mocha.conf".source = ../../conf/kitty-catppuccin-mocha.conf;
    "fastfetch/cat-logo.txt".source = ../../conf/cat-logo.txt;
    "fastfetch/config.jsonc".source = ../../conf/fastfetch.jsonc;
  };

  # Note: Ensure /etc/nixos is owned by the user (sudo chown -R $USER:users /etc/nixos) for proper Git status detection.
}
