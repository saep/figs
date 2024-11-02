{
  config,
  pkgs,
  lib,
  username,
  stateVersion,
  color,
  saepfigsDirectory,
  ...
}:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # command line utilities
    age # encrypt things with SSH-Keys
    bat # should have been rat
    borgbackup
    bottom # similar to htop
    btop # similar to htop
    curl
    delta # diff
    difftastic # diff
    du-dust # similar to du
    duckdb
    fd # similar to find
    gnumake
    graphviz
    htop
    hyperfine # similar to time

    inotify-tools
    isa-l # igzip is a really fast gzip
    jq
    yq-go
    mprocs # tmux-esque for long running processes
    procs # similar to ps
    ripgrep # similar to grep
    tealdeer # common examples instead of man page
    trash-cli
    tokei # similar to cloc (count lines of code)
    wakeonlan
    zip

    nu_scripts

    html-tidy
  ];

  home.shellAliases = {
    g = "git";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    dc = "docker-compose";
  };

  home.file.".ghci".source = ./dev/ghci;

  xdg = {
    configFile."nix/nix.conf".text = ''
      experimental-features = nix-command flakes
    '';

    systemDirs = {
      data = [
        "/usr/local/share"
        "/usr/share"
      ];
    };
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager = {
      enable = true;
    };
    autojump = {
      enable = false;
    };
    atuin = {
      enable = false;
      settings = {
        auto_sync = false;
        update_check = false;
        filter_mode_shell_up_key_binding = "directory";
        history_filter = [
          "^e .*$"
          "^e$"
          "^l .*$"
          "^l$"
          "^ls .*$"
          "^ls$"
          "^nvim$"
          "^z .*$"
          "^z$"
        ];
      };
    };
    readline = {
      enable = false; # carapace should handle completions
      variables = {
        show-all-if-ambiguous = true;
        menu-complete-display-prefix = true;
        colored-completion-prefix = true;
        colored-stats = true;
      };
      extraConfig = ''
        TAB: menu-complete
      '';
    };
    bash = {
      enable = true;
      enableCompletion = true;
      historySize = 10000000;
      historyControl = [
        "erasedups"
        "ignorespace"
        "ignoredups"
      ];
      historyIgnore = [
        "j"
        "br"
        "ls"
        "cd"
        "exit"
        ":wq"
        ":w"
        ":q"
        "z"
      ];
      shellOptions = [
        "histappend"
        "checkwinsize"
        "extglob"
        "globstar"
      ];
      sessionVariables =
        let
          editor = "/home/${username}/.nix-profile/bin/nvim";
        in
        {
          EDITOR = editor;
          VISUAL = editor;
          MANPAGER = "${editor} +Man!";
        };
      shellAliases = {
        g = "git";
        e = "$EDITOR";
      };
      initExtra = ''
        export PATH="$HOME/.local/bin:$PATH"

        PROMPT_COMMAND="''${PROMPT_COMMAND:+$PROMPT_COMMAND$';'}history -a;history -c;history -r"
        PROMPT_COMMAND="''${PROMPT_COMMAND/;;/;}"
        export PROMPT_COMMAND

        bind -x '"\C-g":"br"'
      '';
    };
    broot = {
      enable = true;
      settings = {
        syntax_theme = "MochaDark";
        verbs = [
          {
            execution = "cd {directory}";
            key = "ctrl-g";
            from_shell = true;
          }
          {
            key = "ctrl-t";
            internal = ":toggle_stage";
          }
          {
            key = "ctrl-j";
            internal = ":line_down";
          }
          {
            key = "ctrl-k";
            internal = ":line_up";
          }
          {
            key = "ctrl-l";
            internal = ":panel_right";
          }
          {
            key = "ctrl-h";
            internal = ":panel_left";
          }
          {
            key = "ctrl-o";
            internal = ":parent";
          }
        ];
      };
    };
    carapace = {
      enable = true;
    };
    direnv = {
      enable = true;
    };
    fzf = {
      enable = true;
      changeDirWidgetCommand = "fd --type d";
      changeDirWidgetOptions = [
        "--preview '${pkgs.erdtree}/bin/erd --color force --icons --human --hidden --truncate {}'"
      ];
      fileWidgetCommand = "${pkgs.fd}/bin/fd --type f";
      fileWidgetOptions = [
        "--preview '${pkgs.bat}/bin/bat --force-colorization --paging=never --line-range :100 {}'"
      ];
    };
    git = {
      enable = true;
      delta.enable = true;
      userName = "Sebastian Witte";
      aliases = {
        cb = "switch -c";
        st = "status";
        fa = "fetch --all";
        fo = "fetch origin";
        fu = "fetch uptream";
        pf = "push --force-with-lease";
        rod = "!git fetch origin && git rebase origin/develop";
        rom = "!git fetch origin && git rebase origin/main";
        rum = "!git fetch upstream && git rebase upstream/main";
      };
      extraConfig = {
        difftool = {
          prompt = false;
        };
        rerere = {
          enabled = true;
        };
        core = {
          autocrlf = "input";
        };
        init = {
          defaultBranch = "develop";
        };
        rebase = {
          autoStash = true;
          autosquash = true;
          updateRefs = true;
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
        branch = {
          sort = "-committerdate";
        };
        column = {
          ui = "auto";
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
        ".direnv/"

        "tags"
      ];
    };

    helix = {
      enable = false;
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

    nushell = {
      enable = true;
      environmentVariables =
        let
          editor = "/home/${username}/.nix-profile/bin/nvim";
        in
        {
          EDITOR = editor;
          VISUAL = editor;
          MANPAGER = "${editor} +Man!";
        };
      configFile.source = ./nushell/config.nu;
      extraConfig = ''
        source ${pkgs.nu_scripts}/share/nu_scripts/themes/nu-themes/catppuccin-mocha.nu
      '';
    };

    starship = {
      enable = true;
      settings = {
        # Remove this line to disable the default prompt format
        format = "$all";
      };
    };
    zsh = {
      enable = false;
      dotDir = ".config/zsh";
      syntaxHighlighting.enable = true;
      initExtra = ''
        ${lib.strings.fileContents ./zsh/zshrc}
      '';
    };

    tmux = {
      enable = true;
      clock24 = true;
      prefix = "M-r";
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
    zoxide = {
      enable = true;
    };
  };

  services = {
    ssh-agent.enable = true;

    gpg-agent = {
      enable = true;
      enableSshSupport = false;
    };
  };

}
