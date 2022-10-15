{ config, pkgs, lib, username, stateVersion, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  home.file.".ideavimrc".source = ./ideavimrc;
}
