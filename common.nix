{ config, pkgs, lib, username, stateVersion, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  # misc {{{1
  fonts.fontconfig.enable = true;

  # simple packages {{{1
  home.packages = with pkgs; [
    # command line utilities
    bat
    borgbackup
    bottom # similar to htop
    curl
    delta
    direnv
    difftastic
    du-dust # similar to du 
    exa # similar to ls
    fd # similar to find
    gnumake
    graphviz
    htop
    hyperfine # similar to time
    neovim
    inotify-tools
    jq
    mprocs
    procs # similar to ps
    ripgrep # similar to grep
    tealdeer # common examples instead of man page
    trash-cli
    tokei # similar to cloc (count lines of code)
    wakeonlan
    zip
  ];

  # Shell aliases {{{1
  home.shellAliases = {
    e = "nvim";
    g = "git";
    l = "exa -lah --time-style long-iso";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  };

  # Configuration files {{{1
  home.file.".ghci".source = ./dev/ghci;

  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  # Programs {{{1
  programs = {
    # Home Manager {{{2
    # Let Home Manager install and manage itself.
    home-manager = {
      enable = true;
    };

    # autojump {{{2
    autojump = {
      enable = true;
      enableZshIntegration = true;
    };
    # git {{{2
    git = {
      enable = true;
      difftastic.enable = true;
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

    helix = {
      enable = true;
      settings = {
        theme = "base16";
        editor = {
          line-number = "relative";
        };
        editor.cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
    };

    # starship {{{2
    starship = {
      enable = true;
      enableNushellIntegration = true;
    };
    # nushell {{{2
    nushell = {
      enable = true;
      configFile.source = ./nushell/config.nu;
      envFile.source = ./nushell/env.nu;
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
      shell = "${pkgs.nushell}/bin/nu";
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
      enableSshSupport = false;
      enableZshIntegration = true;
    };
  };

}
# vim: foldmethod=marker
