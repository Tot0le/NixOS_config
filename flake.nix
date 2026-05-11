# /etc/nixos/flake.nix
{
  description = "NixOS and Home Manager System Flake";

  inputs = {
    # Core NixOS packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Standalone Home Manager module
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Catppuccin theme module
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { self, nixpkgs, home-manager, catppuccin, ... }@inputs: {
    
    # Global System Configuration
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };

    # Standalone Home Manager Configurations
    homeConfigurations = {
      anatole = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./users/layouts/all-Feature.nix
          catppuccin.homeModules.catppuccin
          {
            # Define user identity for Home Manager evaluation
            home.username = "anatole";
            home.homeDirectory = "/home/anatole";
          }
        ];
      };
    };
  };
}
