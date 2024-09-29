{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neofetch
    onefetch
    ipfetch
    cpufetch
    ramfetch
    starfetch
    octofetch
    htop
    bottom
    btop
    zfxtop
    kmon

    # vulkan-tools
    # opencl-info
    # clinfo
    # vdpauinfo
    # libva-utils
    nvtopPackages.nvidia
    nvtopPackages.intel
    wlr-randr
    gpu-viewer
    dig
    speedtest-rs
  ];
}
