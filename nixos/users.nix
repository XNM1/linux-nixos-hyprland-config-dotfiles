{ pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.xnm = {
    isNormalUser = true;
    description = "xnm";
    extraGroups = [ "networkmanager" "input" "wheel" "video" "audio" "tss" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      spotify
      pear-desktop
      discord
      telegram-desktop
      vscodium
      brave
    ];
  };

  # Change runtime directory size
  services.logind.settings.Login = {
    RuntimeDirectorySize="8G";
  };
}
