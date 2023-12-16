{ config, pkgs, lib, username, stateVersion, saepfigsDirectory, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  xdg.configFile."nvim/".source = config.lib.file.mkOutOfStoreSymlink "/home/${username}/${saepfigsDirectory}/nvim/";


  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
        lazy-nvim
        catppuccin-nvim
        luasnip
        cmp-buffer
        cmp-cmdline
        cmp_luasnip
        cmp-nvim-lsp
        cmp-nvim-lua
        cmp-path
        comment-nvim
        diffview-nvim
        fzf-lua # for neogit
        haskell-tools-nvim
        lspsaga-nvim
        lualine-nvim
        mini-nvim
        neogit
        saep-neotest
        neotest-haskell
        neotest-plenary
        neotest-rust
        nvim-colorizer-lua
        nvim-cmp
        nvim-dap
        nvim-lspconfig
        nvim-surround
        nvim-treesitter.withAllGrammars
        nvim-treesitter-textobjects
        nvim-treesitter-context
        nvim-ts-autotag
        nvim-web-devicons
        oil-nvim
        orgmode
        rest-nvim
        rust-tools-nvim
        parinfer-rust
        plenary-nvim
        telescope-nvim
        toggleterm-nvim
        vim-exchange
        vim-repeat
        vim-speeddating
        vim-visual-multi
        which-key-nvim
      ];
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
        lua51Packages.jsregexp

        # go
        gcc # tests can't be run without it
        go
        gofumpt
        gopls

        parinfer-rust # magic parens
        vimPlugins.parinfer-rust
      ];
    };
  };

}
