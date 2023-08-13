{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    snowflake.url = "github:snowflakelinux/snowflake-modules";
    nix-data.url = "github:snowflakelinux/nix-data";
    nix-software-center.url = "github:vlinkz/nix-software-center";
    nixos-conf-editor.url = "github:vlinkz/nixos-conf-editor";
    snow.url = "github:snowflakelinux/snow";
    nur.url = "https://github.com/nix-community/NUR/archive/master.tar.gz";
    yandex-unstable.url = "github:ionutnechita/nixos-nixpkgs/local/yandex-browser-update-2023Q3";
  };
  outputs = { self, nixpkgs, nur, yandex-unstable, ... }@inputs:
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        yandex-unstable-repo = import yandex-unstable {
           inherit system;
           config.allowUnfree = true;
         };
      };
    in
    {
      nixosConfigurations."ionutnechita-arz2022" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable nur.overlay ]; })
          ./configuration.nix
          ./snowflake.nix
          inputs.snowflake.nixosModules.snowflake
          inputs.nix-data.nixosModules.${system}.nix-data
          inputs.nur.nixosModules.nur
        ];
        specialArgs = { inherit inputs; inherit system; };
    };
  };
}
