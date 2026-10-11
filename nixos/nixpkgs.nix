{ inputs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      nix-ai-tools = inputs.nix-ai-tools.packages.${final.stdenv.hostPlatform.system};
      wezterm-flake = inputs.wezterm.packages.${final.stdenv.hostPlatform.system}.default;
      omp = inputs.omp.packages.${final.stdenv.hostPlatform.system}.omp;
      herdr = inputs.herdr.packages.${final.stdenv.hostPlatform.system}.herdr;
    })
  ];
  
  # Override packages
  # nixpkgs.config.packageOverrides = pkgs: {
  #   nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
  #     inherit pkgs;
  #   };
  # };
}
