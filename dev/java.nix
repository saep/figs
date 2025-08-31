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

  home.file =
    let
      share = ".local/share";
      vs-ext = "vscode/extensions";
      ext = pkgs.vscode-extensions.vscjava;
    in
    {
      ".ideavimrc".source = ./ideavimrc;
      # I need the lombok jar for jdt language server configuration somehow where I know to find it
      "${share}/java/lombok.jar".source =
        config.lib.file.mkOutOfStoreSymlink "${pkgs.lombok}/share/java/lombok.jar";
      # This vscode plugin is needed to make the debugger via DAP work
      "${share}/${vs-ext}/vscjava.vscode-java-debug".source =
        config.lib.file.mkOutOfStoreSymlink "${ext.vscode-java-debug}/share/${vs-ext}/vscjava.vscode-java-debug";
      # This vscode plugin is needed to run tests from the cursor
      "${share}/${vs-ext}/vscjava.vscode-java-test".source =
        config.lib.file.mkOutOfStoreSymlink "${ext.vscode-java-test}/share/${vs-ext}/vscjava.vscode-java-test";
    };

  home.packages = with pkgs; [
    openjdk
    jbang
  ];
}
