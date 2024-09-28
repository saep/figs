{
  config,
  pkgs,
  lib,
  username,
  stateVersion,
  saepfigsDirectory,
  ...
}:

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
        nvim-autopairs
        nvim-colorizer-lua
        nvim-cmp
        nvim-dap
        one-small-step-for-vimkind
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
        rainbow-delimiters-nvim
        render-markdown
        rustaceanvim
        telescope-nvim
        telescope-fzf-native-nvim
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
        fzf
        tree-sitter

        # bash/shell
        shellcheck
        nodePackages.bash-language-server

        # html/css
        nodePackages.vscode-langservers-extracted

        # json
        nodePackages.vscode-json-languageserver

        # markdown
        comrak

        # nix
        nixfmt-rfc-style

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
      extraLuaPackages =
        luaPkgs: with luaPkgs; [
          # nvim-rest dependencies
          lua-curl
          nvim-nio
          mimetypes
          xml2lua
        ];
    };
  };
}
