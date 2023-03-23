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
    direnv
    difftastic # diff
    du-dust # similar to du 
    evcxr # rust repl
    exa # similar to ls
    fd # similar to find
    gnumake
    graphviz
    htop
    hyperfine # similar to time
    neovim
    inotify-tools
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
    e = "nvim";
    g = "git";
    l = "exa -lah --time-style long-iso";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  };

  home.file.".ghci".source = ./dev/ghci;

  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

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
        modal = true;
      };
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
      keyConfig = ''
        (
            open_help: Some(( code: F(1), modifiers: ( bits: 0,),)),

            move_left: Some(( code: Char('h'), modifiers: ( bits: 0,),)),
            move_right: Some(( code: Char('l'), modifiers: ( bits: 0,),)),
            move_up: Some(( code: Char('k'), modifiers: ( bits: 0,),)),
            move_down: Some(( code: Char('j'), modifiers: ( bits: 0,),)),
            
            popup_up: Some(( code: Char('p'), modifiers: ( bits: 2,),)),
            popup_down: Some(( code: Char('n'), modifiers: ( bits: 2,),)),
            page_up: Some(( code: Char('b'), modifiers: ( bits: 2,),)),
            page_down: Some(( code: Char('f'), modifiers: ( bits: 2,),)),
            home: Some(( code: Char('g'), modifiers: ( bits: 0,),)),
            end: Some(( code: Char('G'), modifiers: ( bits: 1,),)),
            shift_up: Some(( code: Char('K'), modifiers: ( bits: 1,),)),
            shift_down: Some(( code: Char('J'), modifiers: ( bits: 1,),)),

            edit_file: Some(( code: Char('I'), modifiers: ( bits: 1,),)),

            status_reset_item: Some(( code: Char('U'), modifiers: ( bits: 1,),)),

            diff_reset_lines: Some(( code: Char('u'), modifiers: ( bits: 0,),)),
            diff_stage_lines: Some(( code: Char('s'), modifiers: ( bits: 0,),)),

            stashing_save: Some(( code: Char('w'), modifiers: ( bits: 0,),)),
            stashing_toggle_index: Some(( code: Char('m'), modifiers: ( bits: 0,),)),

            stash_open: Some(( code: Char('l'), modifiers: ( bits: 0,),)),

            abort_merge: Some(( code: Char('M'), modifiers: ( bits: 1,),)),
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
    };
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

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = false;
      enableZshIntegration = true;
    };
  };

}
