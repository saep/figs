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

    gitui = {
      enable = true;
      theme = ''
        (
            selected_tab: Reset,
            command_fg: Rgb(205, 214, 244),
            selection_bg: Rgb(88, 91, 112),
            selection_fg: Rgb(205, 214, 244),
            cmdbar_bg: Rgb(24, 24, 37),
            cmdbar_extra_lines_bg: Rgb(24, 24, 37),
            disabled_fg: Rgb(127, 132, 156),
            diff_line_add: Rgb(166, 227, 161),
            diff_line_delete: Rgb(243, 139, 168),
            diff_file_added: Rgb(249, 226, 175),
            diff_file_removed: Rgb(235, 160, 172),
            diff_file_moved: Rgb(203, 166, 247),
            diff_file_modified: Rgb(250, 179, 135),
            commit_hash: Rgb(180, 190, 254),
            commit_time: Rgb(186, 194, 222),
            commit_author: Rgb(116, 199, 236),
            danger_fg: Rgb(243, 139, 168),
            push_gauge_bg: Rgb(137, 180, 250),
            push_gauge_fg: Rgb(30, 30, 46),
            tag_fg: Rgb(245, 224, 220),
            branch_fg: Rgb(148, 226, 213)
        )
      '';
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
