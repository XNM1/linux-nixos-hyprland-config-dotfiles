{ pkgs, ... }:

{
  services.geoclue2.appConfig = {
      "gammastep" = {
        isAllowed = true;
        isSystem = false;
        users = [ "1000" ]; # FIXME: set your user id (to get user id use command 'id -u "your_user_name"')
      };
  };
  
  programs.light.enable = true;

  environment.systemPackages = with pkgs; [
    # wlsunset
    gammastep
    brightnessctl
  ];
}
