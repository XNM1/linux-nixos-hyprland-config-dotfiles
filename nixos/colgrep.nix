{ pkgs, ... }:

{
  # colgrep's managed agent server must point at the NixOS-repacked
  # llama-server; this oneshot keeps the per-user setting correct
  # (idempotent, runs at every login, no network).
  systemd.user.services.colgrep-agent-setup = {
    description = "Point colgrep agent at the system llama-server";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.colgrep}/bin/colgrep settings --agent-llama-server ${pkgs.colgrep-llama-server}/bin/colgrep-llama-server";
    };
  };
}
