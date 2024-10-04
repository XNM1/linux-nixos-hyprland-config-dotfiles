{ pkgs, ... }:

{
  # Linux Kernel
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.kernelParams = [ 
    "splash"
    "quiet"
    "fbcon=nodefer"
    "vt.global_cursor_default=0"
    "kernel.modules_disabled=1"
    "lsm=landlock,lockdown,yama,integrity,apparmor,bpf,tomoyo,selinux"
    "usbcore.autosuspend=-1"
    "video4linux"
    "acpi_rev_override=5"
    "security=selinux"
  ];
  # boot.kernelPatches = [ {
  #      name = "selinux-config";
  #      patch = null;
  #      extraConfig = '' 
  #              SECURITY_SELINUX y
  #              SECURITY_SELINUX_BOOTPARAM n
  #              SECURITY_SELINUX_DEVELOP y
  #              SECURITY_SELINUX_AVC_STATS y
  #              DEFAULT_SECURITY_SELINUX n
  #            '';
  # } ];

  systemd.package = pkgs.systemd.override { withSelinux = true; };

  environment.systemPackages = with pkgs; [
    policycoreutils
  ];
}
