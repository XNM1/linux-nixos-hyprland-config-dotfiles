{
  description = "XNM's NixOS Configuration";

  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { nixpkgs, rust-overlay, ... } @ inputs:
  {
    nixosConfigurations.isitreal-laptop = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ({ pkgs, ... }: {
            nixpkgs.overlays = [ rust-overlay.overlays.default ];
            environment.systemPackages = [ (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml) ];
        })
      ];
    };
  };
}
