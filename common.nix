{ config, pkgs, lib, username, stateVersion, color, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # command line utilities
    bat # should have been rat
    borgbackup
    bottom # similar to htop
    curl
    erdtree
    delta # diff
    difftastic # diff
    du-dust # similar to du 
    fd # similar to find
    gnumake
    graphviz
    htop
    hyperfine # similar to time

    inotify-tools
    isa-l # igzip is a really fast gzip
    jq
    mprocs # tmux-esque for long running processes
    procs # similar to ps
    ripgrep # similar to grep
    rust-script
    tealdeer # common examples instead of man page
    trash-cli
    tokei # similar to cloc (count lines of code)
    wakeonlan
    zip
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
      data = [ "/usr/local/share" "/usr/share" ];
    };
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager = {
      enable = true;
    };
    autojump = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "erasedups" "ignorespace" ];
      historyIgnore = [
        "ls"
        "cd"
        "exit"
        ":wq"
        ":w"
        ":q"
      ];
      shellOptions = [
        "histappend"
        "checkwinsize"
        "extglob"
        "globstar"
      ];
      initExtra = ''
        source "''${HOME}/.nix-profile/etc/profile.d/hm-session-vars.sh"

        export PATH="$HOME/.local/bin:$PATH"

        PROMPT_COMMAND="''${PROMPT_COMMAND:+$PROMPT_COMMAND$';'}history -a;history -c;history -r"
        export PROMPT_COMMAND

        bind 'set show-all-if-ambiguous on'

        export EDITOR=nvim
        export VISUAL="$EDITOR"
      '';
    };
    broot = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        syntax_theme = "MochaDark";
        verbs = [
          {
            execution = "cd {directory}";
            key = "ctrl-t";
            from_shell = true;
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
    direnv = {
      enable = true;
      enableZshIntegration = false;
      enableNushellIntegration = true;
    };
    fzf = {
      enable = true;
      colors = {
        bg = color.background;
        fg = color.foreground;
      };
      changeDirWidgetCommand = "fd --type d";
      changeDirWidgetOptions = [
        "--preview 'erd --force-color --icons --human --hidden --inverted --truncate {}'"
      ];
      fileWidgetCommand = "fd --type f";
      fileWidgetOptions = [
        "--preview 'bat --force-colorization --paging=never --line-range :100 {}'"
      ];
    };
    git = {
      enable = true;
      delta.enable = true;
      userName = "Sebastian Witte";
      aliases = {
        st = "status";
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

    starship =
      let
        flavour = "mocha"; # One of `latte`, `frappe`, `macchiato`, or `mocha`
      in
      {
        enable = true;
        enableNushellIntegration = false;
        settings = {
          # Other config here
          format = "$all"; # Remove this line to disable the default prompt format
          palette = "catppuccin_${flavour}";
        } // builtins.fromTOML (builtins.readFile
          (pkgs.fetchFromGitHub
            {
              owner = "catppuccin";
              repo = "starship";
              rev = "3e3e54410c3189053f4da7a7043261361a1ed1bc"; # Replace with the latest commit hash
              sha256 = "soEBVlq3ULeiZFAdQYMRFuswIIhI9bclIU8WXjxd7oY=";
            } + /palettes/${flavour}.toml));
      };
    nushell = {
      enable = false;
      configFile.source = ./nushell/config.nu;
      envFile.source = ./nushell/env.nu;
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
  };

  services = {
    ssh-agent.enable = true;

    gpg-agent = {
      enable = true;
      enableSshSupport = false;
      enableZshIntegration = true;
    };
  };

}
