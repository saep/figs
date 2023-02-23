{ config, pkgs, lib, username, stateVersion, lspsaga, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  xdg.configFile."nvim".source = ./nvim;

  programs = {
    neovim =
      {
        enable = true;
        viAlias = true;
        withPython3 = true;
        extraPackages = with pkgs; [
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

          # elm
          elmPackages.elm
          elmPackages.elm-test
          elmPackages.elm-format

          # go
          gcc # tests can't be run without it
          go
          gofumpt
          gopls

          elmPackages.elm-language-server
        ];
        plugins = with pkgs.vimPlugins; [
          # dependencies for multiple plugins
          plenary-nvim

          # bling
          lualine-nvim
          nvim-web-devicons
          saeparized-vim
          catppuccin-nvim

          # cmp completion plugins
          cmp-buffer
          cmp-cmdline
          cmp-nvim-lsp
          cmp-nvim-lua
          cmp-path
          cmp_luasnip
          nvim-cmp

          # snippets
          luasnip

          # LSP plugins
          nvim-lspconfig
          lspsaga-nvim
          haskell-tools-nvim

          # simple quality of life plugins
          nvim-tree-lua
          vim-commentary
          vim-exchange
          vim-highlightedyank
          vim-repeat
          vim-speeddating
          vim-surround
          toggleterm-nvim
          leap-nvim

          # treesitter
          nvim-treesitter
          nvim-treesitter-textobjects

          # telescope
          telescope-nvim

          # git
          fugitive
          gitsigns-nvim
          diffview-nvim

          # other
          trouble-nvim
          vim-shellcheck
          hydra-nvim
          orgmode
        ];
      };
  };
}
# vim: foldmethod=marker
