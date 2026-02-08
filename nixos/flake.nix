{
  description = "XNM's NixOS Configuration";

  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      rust-overlay.url = "github:oxalica/rust-overlay";
      wezterm.url = "github:wez/wezterm?dir=nix";
      nix-ai-tools.url = "github:numtide/nix-ai-tools";
  };

  outputs = { nixpkgs, ... } @ inputs:
  {
    nixosConfigurations.isitreal-laptop = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        ./nvidia.nix
        # ./disable-nvidia.nix
        ./opengl.nix
        # ./fingerprint-scanner.nix
        # ./clamav-scanner.nix
        ./yubikey.nix
        ./sound.nix
        ./usb.nix
        ./keyboard.nix
        ./time.nix
        ./swap.nix
        ./bootloader.nix
        ./nix-settings.nix
        ./nixpkgs.nix
        ./gc.nix
        # ./auto-upgrade.nix
        ./linux-kernel.nix
        ./screen.nix
        # ./location.nix
        ./display-manager.nix
        ./theme.nix
        ./internationalisation.nix
        ./fonts.nix
        ./security-services.nix
        ./services.nix
        ./power.nix
        # ./printing.nix
        # ./gnome.nix
        ./hyprland.nix
        ./environment-variables.nix
        ./bluetooth.nix
        ./networking.nix
        # ./mac-randomize.nix
        # ./open-ssh.nix
        ./mosh.nix
        ./firewall.nix
        ./dns.nix
        ./vpn.nix
        ./users.nix
        ./virtualisation.nix
        ./programming-languages.nix
        ./lsp.nix
        ./rust.nix
        ./radicle.nix
        ./wasm.nix
        ./info-fetchers.nix
        ./dev-tools.nix
        ./terminal.nix
        ./llm.nix
        ./work.nix
      ];
    };
  };
}
