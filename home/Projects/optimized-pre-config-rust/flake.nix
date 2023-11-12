{
  description = "A devShell for Rust Development";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      with pkgs;
      {
        devShells.default = mkShell {
          buildInputs = [
            (rust-bin.fromRustupToolchainFile ./rust-toolchain.toml)
            mold
            pkg-config
            openssl
            sqlite
            cargo-deny
            cargo-audit
            cargo-update
            cargo-edit
            cargo-outdated
            cargo-license
            cargo-tarpaulin
            cargo-cross
            cargo-zigbuild
            cargo-nextest
            cargo-spellcheck
            cargo-modules
            cargo-bloat
            taplo
            bacon
            helix
          ];
        };
      }
    );
}
