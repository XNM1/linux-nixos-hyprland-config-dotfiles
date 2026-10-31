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
      tuios = inputs.tuios.packages.${final.stdenv.hostPlatform.system}.tuios;
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
      # llama.cpp build colgrep pins for its managed agent server (same tarball
      # + sha colgrep itself downloads); ubuntu binaries repatched for NixOS.
      # Bump together with a colgrep update when the pinned build changes.
      colgrep-llama-server = final.stdenvNoCC.mkDerivation rec {
        pname = "colgrep-llama-server";
        version = "b11476";
        src = final.fetchurl {
          url = "https://github.com/ggml-org/llama.cpp/releases/download/${version}/llama-${version}-bin-ubuntu-vulkan-x64.tar.gz";
          sha256 = "sha256-W7QwbXkX8z6B79oC5veRrmqC6GvuEhIno6srTo5AQn8=";
        };
        sourceRoot = "llama-${version}";
        dontBuild = true;
        nativeBuildInputs = [ final.autoPatchelfHook ];
        buildInputs = [ final.openssl final.gcc.cc.lib final.vulkan-loader ];
        installPhase = ''
          runHook preInstall
          install -Dm755 llama-server $out/lib/colgrep-llama-server/llama-server
          cp -a --no-dereference lib*.so* $out/lib/colgrep-llama-server/
          mkdir -p $out/bin
          cat > $out/bin/colgrep-llama-server <<'EOF'
          #!/bin/bash
          # colgrep picks the Vulkan device with most free memory, which is the
          # iGPU when it advertises shared RAM. Strip that choice, force dGPU.
          # Vulkan0 = NVIDIA with current ICD order; COLGREP_VULKAN_DEVICE overrides.
          declare -a args=("$@") out=()
          i=0
          while [ $i -lt ''${#args[@]} ]; do
            case "''${args[$i]}" in
              --device) ((i++));;
              --device=*) ;;
              *) out+=("''${args[$i]}");;
            esac
            ((i++))
          done
          exec "$(dirname "$0")/../lib/colgrep-llama-server/llama-server" \
            --device "''${COLGREP_VULKAN_DEVICE-Vulkan0}" "''${out[@]}"
          EOF
          sed -i "1c #!${final.bash}/bin/bash" $out/bin/colgrep-llama-server
          chmod +x $out/bin/colgrep-llama-server
          runHook postInstall
        '';
        meta = {
          mainProgram = "colgrep-llama-server";
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
