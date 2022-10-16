{ config, pkgs, lib, username, stateVersion, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  # misc {{{1
  fonts.fontconfig.enable = true;

  # simple packages {{{1
  home.packages = with pkgs; [
    # bash/shell
    shellcheck
    # elm
    elmPackages.elm
    elmPackages.elm-test
    elmPackages.elm-format
    # nix
    nixfmt
    rnix-lsp
    # lua
    sumneko-lua-language-server
    # command line utilities
    bat
    curl
    direnv
    fd
    graphviz
    jq
    lazygit
    ripgrep
    stow # TODO remove once everything is moved to home-manager
    wakeonlan
    zip
  ];

  # Shell aliases {{{1
  home.shellAliases = {
    e = "nvim";
    g = "git";
    l = "ls -lah --color=tty";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  };

  # Configuration files {{{1
  home.file.".ghci".source = ./dev/ghci;
   
  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  # Due to the way progrms.neovim works, it is currently not possible
  # to simply define the nvim directory here or in the neovim module.
  xdg.configFile."nvim/after".source = ./nvim/after;
  xdg.configFile."nvim/lua".source = ./nvim/lua;

  # Programs {{{1
  programs = {
    # Home Manager {{{2
    # Let Home Manager install and manage itself.
    home-manager = {
      enable = true;
    };

    # git {{{2
    git = {
      enable = true;
      delta.enable = true;
      userName = "Sebastian Witte";
      extraConfig = {
        difftool = {
          prompt = false;
        };
        mergetool.fugitive.cmd = ''nvim -f -c "Gvdiffsplit!" "$MERGED"'';
        merge.tool = "fugitive";
        core = {
          autocrlf = "input";
        };
        init = {
          defaultBranch = "develop";
        };
        merge = {
          conflictstyle = "diff3";
        };
        pull = {
          rebase = true;
        };
        push = {
          default = "simple";
        };
        github = {
          user = "saep";
        };
      };
      ignores = [
        # vim temporary files
        "*.swp"
        "*.swo"
        "*~"
        ".netrwhist"

        # Haskell
        ".stack-work/"
        "dist/"
        "dist-newstyle/"
        "cabal.project.local*"

        # intellij
        ".idea/"
        "*.iml"

        # eclipse
        ".classpath"
        ".project"
        ".settings/"

        # Java
        "target/"

        # custom shell variables
        ".envrc"
        ".env"

        "tags"
      ];
    };

    # neovim {{{2
    neovim =
      {
        enable = true;
        viAlias = true;
        withPython3 = true;
        extraConfig = builtins.concatStringsSep "\n" [
          ''
            lua << EOF
            ${lib.strings.fileContents ./nvim/init.lua}
            EOF
          ''
        ];
        extraPackages = with pkgs; [
          curl
          jq
          tree-sitter

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
          lsp_signature-nvim
          lspsaga-nvim

          # simple quality of life plugins
          nvim-tree-lua
          vim-commentary
          vim-exchange
          vim-highlightedyank
          vim-repeat
          vim-speeddating
          vim-surround
          vim-vinegar
          toggleterm-nvim

          # treesitter
          (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
          nvim-treesitter-textobjects

          # telescope
          telescope-nvim

          # git
          fugitive
          gitsigns-nvim
          diffview-nvim

          # other
          trouble-nvim
          nvim-colorizer-lua
          vim-shellcheck
          hydra-nvim
          orgmode
        ];
      };

    # zsh {{{2
    zsh = {
      enable = true;
      dotDir = ".config/zsh";
      enableSyntaxHighlighting = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "colored-man-pages"
          "direnv"
          "fancy-ctrl-z"
          "git"
          "mvn"
          "pass"
          "ripgrep"
          "stack"
          "themes"
        ];
        custom = "${builtins.toString ./.}/zsh/custom";
        theme = "saep";
      };
      initExtra = ''
        ${lib.strings.fileContents ./zsh/zshrc}
      '';
    };

    # tmux {{{2
    tmux = {
      enable = true;
      clock24 = true;
      prefix = "M-r";
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "screen-256color";
      keyMode = "vi";
      extraConfig = ''
        # window title
        set-option -g set-titles on
        # window number,program name,active (or not)
        set-option -g set-titles-string '#S:#I.#P #W'
        set-window-option -g automatic-rename on 

        # status bar
        set-option -g status-justify right
        set-option -g status-bg default
        set-option -g status-fg default
        set-option -g status-interval 5
        set-option -g status-left-length 30
        set-option -g status-left '#[fg=magenta]» #[fg=blue]#T#[default]'
        set-option -g status-right "#[fg=cyan]»» #[fg=blue,bold] #S"
        set-option -g visual-activity on
        set-window-option -g monitor-activity on
        # clock
        set-window-option -g clock-mode-colour cyan

        # vi like movement
        bind-key -r j select-pane -D
        bind-key -r k select-pane -U
        bind-key -r h select-pane -L
        bind-key -r l select-pane -R
      '';
    };
  };

  # services {{{1
  services = {
    # gpg-agent {{{2
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
    };
  };

}
# vim: foldmethod=marker
