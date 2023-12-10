{ ... }:

{
  # Nix Configuration
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];    
  };
}
