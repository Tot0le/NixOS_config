{ pkgs, ... }:

{
  # Enable Docker daemon
  virtualisation.docker.enable = true;

  # Add user to docker group to avoid using sudo for docker commands
  users.users.anatole.extraGroups = [ "docker" ];

  # Install docker-compose helper
  environment.systemPackages = [
    pkgs.docker-compose
  ];
}
