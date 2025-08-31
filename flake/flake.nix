{
  description = "ionutnechita's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Optional: Add home-manager if needed
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, nur, ... }@inputs: {
    nixosConfigurations.ionutnechita-arz2022 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        ./cachix.nix
        
        # Configure NUR overlay
        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [
            nur.overlays.default
          ];
        })
      ];
    };
  };
}
