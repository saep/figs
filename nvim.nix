{ config, pkgs, lib, username, stateVersion, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  xdg.configFile."nvim".source = ./nvim;

  home.packages = with pkgs; [
          curl
          jq
          tree-sitter

          # bash/shell
          shellcheck

          # nix
          nixfmt
          rnix-lsp

          # lua
          sumneko-lua-language-server
          lua51Packages.jsregexp

          # elm
          elmPackages.elm
          elmPackages.elm-test
          elmPackages.elm-format
          elmPackages.elm-language-server

          # go
          gcc # tests can't be run without it
          go
          gofumpt
          gopls
  ];
}
