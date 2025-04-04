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

  xdg.configFile."nvim/".source =
    config.lib.file.mkOutOfStoreSymlink "/home/${username}/${saepfigsDirectory}/nvim/";

  xdg.configFile."vale/.vale.ini".text = ''
    MinAlertLevel = suggestion

    Packages = Google, write-good

    [*.{md,rst}]
    BasedOnStyles = Vale, Google, write-good
  '';

  catppuccin.nvim.enable = false; # incompatible with how I configure neovim
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
        cmp-conjure
        cmp_luasnip
        cmp-nvim-lsp
        cmp-nvim-lua
        cmp-path
        conform-nvim
        conjure
        diffview-nvim
        fzf-lua # for neogit
        image-nvim
        leap-nvim
        lualine-nvim
        mini-nvim
        neodev-nvim
        neogit
        nvim-colorizer-lua
        nvim-cmp
        nvim-dap
        one-small-step-for-vimkind
        nvim-dap-ui
        nvim-jdtls # java language server helper plugin
        nvim-lint
        nvim-lspconfig
        nvim-surround
        (nvim-treesitter.withPlugins (_: nvim-treesitter.allGrammars))
        nvim-treesitter-context
        nvim-ts-autotag
        nvim-web-devicons
        oil-nvim
        rest-nvim
        plenary-nvim
        rainbow-delimiters-nvim
        render-markdown-nvim
        snacks-nvim
        telescope-nvim
        telescope-fzf-native-nvim
        telescope-ui-select-nvim
        text-case-nvim
        vim-exchange
        vim-dadbod
        vim-dadbod-ui
        vim-dadbod-completion
        vim-repeat
        vim-sexp
        vim-sexp-mappings-for-regular-people
        vim-speeddating
        vim-visual-multi
        which-key-nvim
        twilight-nvim
      ];
      extraPackages = with pkgs; [
        curl
        jq
        yq
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

        #rust
        evcxr
        lldb

        # scheme
        mitscheme

        # nix
        nixd
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

        # clojure
        clojure
        clojure-lsp

        # postgresql
        pgformatter

        # spell and gramar checker
        vale

        # postgres
        pgformatter

        # java
        jdt-language-server

        imagemagick
      ];
    };
  };
}
