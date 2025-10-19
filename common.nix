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

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
    firefox.profiles.default.enable = false;
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # command line utilities
    age # encrypt things with SSH-Keys
    ast-grep # grep for source code
    babashka # bash, but clojure
    borgbackup
    curl
    delta # diff
    du-dust # similar to du
    duckdb
    erdtree # tree
    gnumake
    graphviz
    hyperfine # similar to time

    inotify-tools
    isa-l # igzip is a really fast gzip
    yq-go
    mprocs # tmux-esque for long running processes
    sqlite
    trash-cli
    tokei # similar to cloc (count lines of code)
    wakeonlan
    unzip
    zip

    nu_scripts

    html-tidy
    shellcheck
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
    configFile."nushell/keybindings.nu".source =
      config.lib.file.mkOutOfStoreSymlink "/home/${username}/${saepfigsDirectory}/nushell/keybindings.nu";

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
    bat.enable = true;
    btop.enable = true;
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
          FLAKE_PATH = "${saepfigsDirectory}";
          GOPATH = "/home/${username}/.cache/go";
          GOBIN = "/home/${username}/.local/bin";
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

        unset LD_LIBRARY_PATH
        unset LIBVA_DRIVERS_PATH
        unset LIBGL_DRIVERS_PATH
      '';
    };
    bottom.enable = true;
    broot = {
      enable = false;
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
      enableNushellIntegration = false; # done manually to hide deprecations
    };
    direnv = {
      enable = true;
    };
    fd = {
      enable = true;
      ignores = [
        ".git/"
        ".jj/"
        "target/"
      ];
    };
    fzf = {
      enable = true;
      changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d --hidden";
      changeDirWidgetOptions = [
        "--preview '${pkgs.erdtree}/bin/erd --color force --icons --human --hidden --truncate {}'"
      ];
      fileWidgetCommand = "${pkgs.fd}/bin/fd --type file --hidden";
      fileWidgetOptions = [
        "--preview '${pkgs.bat}/bin/bat --force-colorization --paging=never --line-range :100 {}'"
      ];
    };
    jujutsu = {
      enable = true;
      settings = {
        user = {
          email = "saep@saep.rocks";
          name = "Sebastian Witte";
        };
        revset-aliases = {
          "immutable_heads()" = "trunk() | tags() | remote_branches()";
        };
      };
    };
    jjui = {
      enable = true;
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

        # jujutsu
        ".jj/"

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
        ".factorypath"

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

    htop.enable = true;

    jq.enable = true;

    nushell =
      let
        editor = "/home/${username}/.nix-profile/bin/nvim";
      in
      {
        enable = true;
        environmentVariables = {
          EDITOR = editor;
          VISUAL = editor;
          MANPAGER = "${editor} +Man!";
          FLAKE_PATH = "${saepfigsDirectory}";
          # These are set by nixgl and shouldn't be inside a shell session
          LD_LIBRARY_PATH = null;
        };
        configFile.source = ./nushell/config.nu;
        extraConfig = ''
          source ${pkgs.nu_scripts}/share/nu_scripts/themes/nu-themes/catppuccin-mocha.nu
          source ${
            pkgs.runCommand "carapace-nushell-config.nu" { } ''
              ${pkgs.carapace}/bin/carapace _carapace nushell | sed 's|"/homeless-shelter|$"($env.HOME)|g' | sed 's|get -i |get --optional |g' >> "$out"
            ''
          }
        '';
        shellAliases = {
          c = "docker compose";
          d = "docker";
          e = "${editor}";
        };
      };
    ripgrep.enable = true;
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

    tealdeer.enable = true;

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
