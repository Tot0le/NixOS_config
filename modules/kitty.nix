{ pkgs, ... }:

{
  # Install kitty terminal emulator
  environment.systemPackages = [
    pkgs.kitty
  ];

  # Link external kitty configuration file
  # Path is relative to this module's location
  environment.etc."xdg/kitty/kitty.conf".source = ../conf/kitty.conf;
}
