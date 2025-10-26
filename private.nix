{
  config,
  pkgs,
  lib,
  username,
  stateVersion,
  ...
}:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  programs.git.settings.user.email = "saep@saep.rocks";
}
