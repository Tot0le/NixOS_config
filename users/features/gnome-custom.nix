# /etc/nixos/users/features/gnome-custom.nix
{ config, pkgs, ... }:

let
  # Path to your custom background image
  # IMPORTANT: Ensure this file exists before running the switch command
  desktopWallpaper = "${../../conf/wallpaper.jpg}";
in
{
  # Install essential GNOME extensions for a modern workflow
  home.packages = with pkgs.gnomeExtensions; [
    dash-to-dock
    blur-my-shell
    just-perfection
    appindicator
  ];

  # Configure global GTK theme and icons
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Tela-circle-dark";
      package = pkgs.tela-circle-icon-theme;
    };
  };

  # Force dark mode, apply wallpaper, and enable extensions automatically via dconf
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/gnome/desktop/background" = {
      picture-uri = "file://${desktopWallpaper}";
      picture-uri-dark = "file://${desktopWallpaper}";
    };
    "org/gnome/desktop/screensaver" = {
      picture-uri = "file://${desktopWallpaper}";
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        "blur-my-shell@aunetx"
        "just-perfection-desktop@just-perfection"
        "appindicatorsupport@rgcjonas.gmail.com"
      ];
    };
  };
}
