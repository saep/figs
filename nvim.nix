{ config, pkgs, lib, username, stateVersion, saepfigsDirectory, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  xdg.configFile."nvim/".source = config.lib.file.mkOutOfStoreSymlink
    "/home/${username}/${saepfigsDirectory}/nvim/";

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
        conform-nvim
        diffview-nvim
        fzf-lua # for neogit
        harpoon2
        haskell-tools-nvim
        leap-nvim
        lspsaga-nvim
        lualine-nvim
        mini-nvim
        neodev-nvim
        neogit
        neotest
        neotest-haskell
        neotest-plenary
        nvim-colorizer-lua
        nvim-cmp
        nvim-dap
        nvim-dap-ui
        nvim-lspconfig
        nvim-surround
        nvim-treesitter.withAllGrammars
        nvim-treesitter-textobjects
        nvim-treesitter-context
        nvim-ts-autotag
        nvim-web-devicons
        oil-nvim
        rest-nvim
        parinfer-rust
        plenary-nvim
        rustaceanvim
        telescope-nvim
        telescope-ui-select-nvim
        text-case-nvim
        toggleterm-nvim
        vim-exchange
        vim-dadbod
        vim-dadbod-ui
        vim-dadbod-completion
        vim-repeat
        vim-speeddating
        vim-visual-multi
        which-key-nvim
        twilight-nvim
        zen-mode-nvim
      ];
      extraPackages = with pkgs; [
        curl
        jq
        tree-sitter

        # bash/shell
        shellcheck
        nodePackages.bash-language-server

        # nix
        nixfmt

        # lua
        sumneko-lua-language-server
        lua51Packages.jsregexp
        stylua

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
