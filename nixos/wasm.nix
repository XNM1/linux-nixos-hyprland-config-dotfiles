{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wasmedge
    # wasmer
    lunatic
    wasmi
    wrangler
    fermyon-spin
    wash-cli
    # wasm3
  ];
}
