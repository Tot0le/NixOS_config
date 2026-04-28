# /etc/nixos/modules/docker.nix
{ pkgs, userList, ... }:

{
  # Enable Docker virtualization
  virtualisation.docker.enable = true;

  # Grant docker permissions to all primary users
  users.users = pkgs.lib.genAttrs userList (name: {
    extraGroups = [ "docker" ];
  });

  environment.systemPackages = [
    pkgs.docker-compose
  ];
}
