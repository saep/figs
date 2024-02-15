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
      enable = false;
    };
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "erasedups" "ignorespace" "ignoredups" ];
      historyIgnore = [
        "j"
        "br"
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

        bind -x '"\C-g":"br"'

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

    starship =
      let
        flavour = "mocha"; # One of `latte`, `frappe`, `macchiato`, or `mocha`
      in
      {
        enable = true;
        enableNushellIntegration = true;
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
      enable = true;
      configFile.source = ./nushell/config.nu;
      envFile.source = ./nushell/env.nu;
      shellAliases = {
        e = "${pkgs.neovim}";
      };
      environmentVariables = {
        EDITOR = "${pkgs.neovim}";
        VISUAL = "${pkgs.neovim}";
      };
      extraConfig = ''
        source ${
          pkgs.runCommand "br.nushell" { nativeBuildInputs = [ pkgs.broot ]; }
          "broot --print-shell-function nushell | sed 's/def-env/def --env/' > $out"
        }

        # https://github.com/nushell/nu_scripts/blob/main/themes/nu-themes/catppuccin-mocha.nu

        const color_palette = {
            rosewater: "#f5e0dc"
            flamingo: "#f2cdcd"
            pink: "#f5c2e7"
            mauve: "#cba6f7"
            red: "#f38ba8"
            maroon: "#eba0ac"
            peach: "#fab387"
            yellow: "#f9e2af"
            green: "#a6e3a1"
            teal: "#94e2d5"
            sky: "#89dceb"
            sapphire: "#74c7ec"
            blue: "#89b4fa"
            lavender: "#b4befe"
            text: "#cdd6f4"
            subtext1: "#bac2de"
            subtext0: "#a6adc8"
            overlay2: "#9399b2"
            overlay1: "#7f849c"
            overlay0: "#6c7086"
            surface2: "#585b70"
            surface1: "#45475a"
            surface0: "#313244"
            base: "#1e1e2e"
            mantle: "#181825"
            crust: "#11111b"
        }

        let catppuccin_mocha = {
            separator: $color_palette.overlay0
            leading_trailing_space_bg: { attr: "n" }
            header: { fg: $color_palette.blue attr: "b" }
            empty: $color_palette.lavender
            bool: $color_palette.lavender
            int: $color_palette.peach
            duration: $color_palette.text
            filesize: {|e|
                  if $e < 1mb {
                    $color_palette.green
                } else if $e < 100mb {
                    $color_palette.yellow
                } else if $e < 500mb {
                    $color_palette.peach
                } else if $e < 800mb {
                    $color_palette.maroon
                } else if $e > 800mb {
                    $color_palette.red
                }
            }
            date: {|| (date now) - $in |
                if $in < 1hr {
                    $color_palette.green
                } else if $in < 1day {
                    $color_palette.yellow
                } else if $in < 3day {
                    $color_palette.peach
                } else if $in < 1wk {
                    $color_palette.maroon
                } else if $in > 1wk {
                    $color_palette.red
                }
            }
            range: $color_palette.text
            float: $color_palette.text
            string: $color_palette.text
            nothing: $color_palette.text
            binary: $color_palette.text
            cellpath: $color_palette.text
            row_index: { fg: $color_palette.mauve attr: "b" }
            record: $color_palette.text
            list: $color_palette.text
            block: $color_palette.text
            hints: $color_palette.overlay1
            search_result: { fg: $color_palette.red bg: $color_palette.text }

            shape_and: { fg: $color_palette.pink attr: "b" }
            shape_binary: { fg: $color_palette.pink attr: "b" }
            shape_block: { fg: $color_palette.blue attr: "b" }
            shape_bool: $color_palette.teal
            shape_custom: $color_palette.green
            shape_datetime: { fg: $color_palette.teal attr: "b" }
            shape_directory: $color_palette.teal
            shape_external: $color_palette.teal
            shape_externalarg: { fg: $color_palette.green attr: "b" }
            shape_filepath: $color_palette.teal
            shape_flag: { fg: $color_palette.blue attr: "b" }
            shape_float: { fg: $color_palette.pink attr: "b" }
            shape_garbage: { fg: $color_palette.text bg: $color_palette.red attr: "b" }
            shape_globpattern: { fg: $color_palette.teal attr: "b" }
            shape_int: { fg: $color_palette.pink attr: "b" }
            shape_internalcall: { fg: $color_palette.teal attr: "b" }
            shape_list: { fg: $color_palette.teal attr: "b" }
            shape_literal: $color_palette.blue
            shape_match_pattern: $color_palette.green
            shape_matching_brackets: { attr: "u" }
            shape_nothing: $color_palette.teal
            shape_operator: $color_palette.peach
            shape_or: { fg: $color_palette.pink attr: "b" }
            shape_pipe: { fg: $color_palette.pink attr: "b" }
            shape_range: { fg: $color_palette.peach attr: "b" }
            shape_record: { fg: $color_palette.teal attr: "b" }
            shape_redirection: { fg: $color_palette.pink attr: "b" }
            shape_signature: { fg: $color_palette.green attr: "b" }
            shape_string: $color_palette.green
            shape_string_interpolation: { fg: $color_palette.teal attr: "b" }
            shape_table: { fg: $color_palette.blue attr: "b" }
            shape_variable: $color_palette.pink

            background: $color_palette.base
            foreground: $color_palette.text
            cursor: $color_palette.blue
        }

        $env.config = ($env.config | merge {color_config: $catppuccin_mocha})
      '';
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
      enableZshIntegration = true;
    };
  };

}
