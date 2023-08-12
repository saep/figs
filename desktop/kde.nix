{ config, pkgs, lib, username, stateVersion, isNixos, color, dpi, ... }:
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;
}
