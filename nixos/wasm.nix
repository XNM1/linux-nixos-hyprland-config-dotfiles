{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wasmedge
    wasmer
    lunatic
    wasmi
    # wasm3
  ];
}
