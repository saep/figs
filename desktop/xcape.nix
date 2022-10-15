{ config, pkgs, lib, username, stateVersion, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  services.xcape = {
    enable = true;
    timeout = 150;
    mapExpression = {
      Alt_L = "Super_L|space";
      Control_L = "Escape";
      Super_L = "Escape";
    };
  };
}
