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
        blink-cmp
        blink-compat
        catppuccin-nvim
        luasnip
        conform-nvim
        conjure
        diffview-nvim
        fzf-lua
        kulala-nvim
        leap-nvim
        lualine-nvim
        neodev-nvim
        neogit
        nvim-colorizer-lua
        nvim-dap
        one-small-step-for-vimkind
        neotest
        neotest-plenary
        nvim-dap-ui
        nvim-jdtls # java language server helper plugin
        nvim-lspconfig
        nvim-spider
        nvim-surround
        (nvim-treesitter.withPlugins (
          _: nvim-treesitter.allGrammars ++ [ pkgs.tree-sitter-grammars.kulala-http ]
        ))
        nvim-treesitter-context
        nvim-treesitter-textobjects
        nvim-ts-autotag
        nvim-web-devicons
        oil-nvim
        plenary-nvim
        rainbow-delimiters-nvim
        render-markdown-nvim
        rustaceanvim
        snacks-nvim
        text-case-nvim
        vim-exchange
        vim-dadbod
        vim-dadbod-ui
        vim-dadbod-completion
        vim-repeat
        vim-sexp
        vim-sexp-mappings-for-regular-people
        vim-speeddating
        which-key-nvim
      ];
      extraPackages = with pkgs; [
        curl
        jq
        yq
        fzf
        tree-sitter

        # bash/shell
        nodePackages.bash-language-server

        # html/css/json
        vscode-langservers-extracted

        # typescript
        deno
        typescript-language-server

        # markdown
        comrak

        #rust
        evcxr
        lldb

        # scheme
        mitscheme

        # nix
        nixd
        nixfmt

        # lua
        lua-language-server
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

        # postgres
        pgformatter

        # java
        jdt-language-server

        imagemagick

        # xml
        lemminx
        xmlstarlet
      ];
    };
  };
}
