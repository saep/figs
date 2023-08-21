{ config, pkgs, lib, username, stateVersion, ... }:

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
    delta # diff
    difftastic # diff
    du-dust # similar to du 
    fd # similar to find
    gnumake
    graphviz
    htop
    hyperfine # similar to time
    neovim
    inotify-tools
    isa-l # igzip is a really fast gzip
    jq
    mprocs # tmux-esque for long running processes
    parinfer-rust # magic parens
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
      enableZshIntegration = true;
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
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
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
      enable = true;
      dotDir = ".config/zsh";
      enableSyntaxHighlighting = true;
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
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
    };
  };

}
