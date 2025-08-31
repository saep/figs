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

  home.file.".ideavimrc".source = ./ideavimrc;

  # I need the lombok jar for jdt language server configuration somehow where I know to find it
  home.file.".local/share/java/lombok.jar".source =
    config.lib.file.mkOutOfStoreSymlink "${pkgs.lombok}/share/java/lombok.jar";

}
