{ ... }:

{
  # Open ports in the firewall.
  networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [ 3000 ];
  # networking.firewall.allowedUDPPorts = [ 3000 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
