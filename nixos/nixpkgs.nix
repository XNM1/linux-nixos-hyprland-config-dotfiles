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
      # Core release tarball (static engine, no self-extracting bundle). Upstream flake
      # unusable here: opam-nix breaks pure eval and impure ('url' too short); no overlay output.
      # Bump version+hash together: nix hash file --type sha256 --base16 opengrep-core_linux_x86.tar.gz
      opengrep = final.stdenvNoCC.mkDerivation rec {
        pname = "opengrep";
        version = "1.32.0";
        src = final.fetchurl {
          url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_linux_x86.tar.gz";
          sha256 = "939b341900249a03ea559148cfd023cd4d4bb4654deec770f65c344aad63e6d1";
        };
        sourceRoot = ".";
        dontBuild = true;
        installPhase = ''
          runHook preInstall
          install -Dm755 opengrep-core $out/bin/opengrep
          runHook postInstall
        '';
        meta = {
          mainProgram = "opengrep";
          platforms = [ "x86_64-linux" ];
        };
      };
      # cargo-dist release binary; runtime downloads (encoder weights, agent 2B model,
      # llama.cpp) all go to ~/.cache/colgrep, CPU/Vulkan inference, no telemetry.
      colgrep = final.stdenvNoCC.mkDerivation rec {
        pname = "colgrep";
        version = "1.8.5";
        src = final.fetchurl {
          url = "https://github.com/lightonai/next-plaid/releases/download/v${version}/colgrep-x86_64-unknown-linux-gnu.tar.xz";
          sha256 = "sha256-Uy4dpzn2tdSJza79IMWRj6G7D/n0VsiQmOtJpjea4gU=";
        };
        dontBuild = true;
        nativeBuildInputs = [ final.autoPatchelfHook final.makeWrapper ];
        buildInputs = [ final.openssl final.libgcc ];
        # the downloaded ONNX Runtime gpu build dlopen()s libstdc++ at runtime
        installPhase = ''
          runHook preInstall
          install -Dm755 colgrep $out/lib/colgrep/colgrep
          makeWrapper $out/lib/colgrep/colgrep $out/bin/colgrep \
            --prefix LD_LIBRARY_PATH : "${final.gcc.cc.lib}/lib"
          runHook postInstall
        '';
        meta = {
          mainProgram = "colgrep";
          platforms = [ "x86_64-linux" ];
        };
      };
    })
  ];
  
  # Override packages
  # nixpkgs.config.packageOverrides = pkgs: {
  #   nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
  #     inherit pkgs;
  #   };
  # };
}
