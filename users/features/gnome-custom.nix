# /etc/nixos/users/features/gnome-custom.nix
{ config, pkgs, lib, ... }:

let
  # Default fallback wallpaper
  defaultWallpaper = "${../../conf/theme/wallpaper.jpg}";
in
{
  # Define per-user customization options
  options.my.gnome = {
    wallpaper = lib.mkOption {
      type = lib.types.str;
      default = defaultWallpaper;
      description = "Path to the user wallpaper file.";
    };
    desktopIcons = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable desktop icons (DING).";
    };
  };

  config = {
    # Install extensions based on user-defined options
    home.packages = with pkgs.gnomeExtensions; [
      dash-to-dock
      blur-my-shell
      just-perfection
      appindicator
    ] ++ lib.optionals config.my.gnome.desktopIcons [
      desktop-icons-ng-ding
    ];

    # Manage global desktop appearance via GTK
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

    # Persist theme and extension settings in the dconf database
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
      "org/gnome/desktop/background" = {
        picture-uri = "file://${config.my.gnome.wallpaper}";
        picture-uri-dark = "file://${config.my.gnome.wallpaper}";
      };
      "org/gnome/desktop/screensaver" = {
        picture-uri = "file://${config.my.gnome.wallpaper}";
      };
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          "dash-to-dock@micxgx.gmail.com"
          "blur-my-shell@aunetx"
          "just-perfection-desktop@just-perfection"
          "appindicatorsupport@rgcjonas.gmail.com"
        ] ++ lib.optionals config.my.gnome.desktopIcons [
          "ding@rastersoft.com"
        ];
      };
      "org/gnome/shell/extensions/dash-to-dock" = {
        intellihide = true;
      };
    };

    # Prevent basic wallpaper: Copy default wallpaper if the user's target path doesn't exist yet
    home.activation.initWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
      TARGET_WALLPAPER="${config.my.gnome.wallpaper}"
      TARGET_DIR=$(dirname "$TARGET_WALLPAPER")
      
      if [ ! -f "$TARGET_WALLPAPER" ]
      then
        $DRY_RUN_CMD mkdir -p "$TARGET_DIR"
        $DRY_RUN_CMD cp ${defaultWallpaper} "$TARGET_WALLPAPER"
        $DRY_RUN_CMD chmod 644 "$TARGET_WALLPAPER"
      fi
    '';
  };
 }
