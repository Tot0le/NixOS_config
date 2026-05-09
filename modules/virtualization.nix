# /etc/nixos/modules/virtualization.nix
{ pkgs, userList, ... }:

{
  # Enable VirtualBox host service
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  # Add users to the vboxusers group
  users.groups.vboxusers.members = userList;

  environment.systemPackages = [
    pkgs.virtualbox
  ];
}
