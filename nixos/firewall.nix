{ pkgs, ... }:

{
  # Open ports in the firewall.
  networking.firewall.enable = true;

  # Mitigate unsolicited cloud-metadata probes reported for Qwen3.8-Flash-Next
  # (Cohere, 2026-10-26) by blocking connections to the metadata IP.
  # Match destinations, not payload strings: the former aliyuncs.com matcher
  # blocked legitimate DGX HTTP requests when prompts mentioned that domain.
  networking.firewall.extraCommands = ''
    iptables=${pkgs.iptables}/bin/iptables
    $iptables -I OUTPUT 1 -d 169.254.169.254/32 -m limit --limit 6/min -j LOG --log-prefix "egress-metadata: "
    $iptables -I OUTPUT 2 -d 169.254.169.254/32 -j REJECT
  '';
  # networking.firewall.allowedTCPPorts = [ 3000 ];
  # networking.firewall.allowedUDPPorts = [ 3000 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
