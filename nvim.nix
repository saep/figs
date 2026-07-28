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

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/home/${username}/${saepfigsDirectory}/nvim";

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
      sideloadInitLua = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withRuby = false;
      withPython3 = false;
      plugins = with pkgs.vimPlugins; [
        blink-cmp
        blink-compat
        catppuccin-nvim
        luasnip
        conform-nvim
        fzf-lua
        kulala-nvim
        leap-nvim
        lualine-nvim
        neodev-nvim
        nvim-colorizer-lua
        nvim-dap
        one-small-step-for-vimkind
        nvim-dap-ui
        nvim-lspconfig
        nvim-spider
        nvim-surround
        (nvim-treesitter.withPlugins (_: nvim-treesitter.allGrammars))
        nvim-ts-autotag
        nvim-web-devicons
        oil-nvim
        plenary-nvim
        rainbow-delimiters-nvim
        render-markdown-nvim
        rustaceanvim
        snacks-nvim
        text-case-nvim
        trouble-nvim
        vim-exchange
        vim-dadbod
        vim-dadbod-ui
        vim-dadbod-completion
        vim-fugitive
        vim-repeat
        vim-sexp
        vim-sexp-mappings-for-regular-people
        vim-speeddating
        which-key-nvim
        zellij-nav-nvim
      ];
      extraPackages = with pkgs; [
        curl
        jq
        yq
        fzf
        tree-sitter

        # bash/shell
        bash-language-server

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

        # postgresql
        pgformatter

        imagemagick

        # xml
        lemminx
        xmlstarlet
      ];
    };
  };
}
