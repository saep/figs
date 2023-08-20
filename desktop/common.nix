# Applications used on desktop computers and laptops
{ config, pkgs, lib, username, stateVersion, dpi, color, isNixos ? false, ... }:
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  fonts.fontconfig.enable = true;
  home.language = {
    base = "en_US.UTF-8";
  };

  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
    };
    systemDirs = {
      data = [ "/home/${username}/.nix-profile/share" ];
    };
  };

  home.packages =
    with pkgs;
    [
      pkgs.nixgl.nixGLIntel
      keepassxc
      neovide
      chromium

      xdg-utils

      # other
      remmina
      pavucontrol

      # fonts
      (nerdfonts.override { fonts = [ "FiraCode" "Hasklig" "DroidSansMono" ]; })
    ];

  programs = {
    firefox = {
      enable = true;
      package =
        pkgs.firefox.override { cfg = { enableTridactylNative = true; }; };
      profiles = {
        default = {
          id = 0;
          settings = {
            "browser.aboutConfig.showWarning" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.startup.page" = 3; # restore previous tabs and windows
            "browser.urlbar.placeholderName" = "DuckDuckGo";
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
            "media.hardwaremediakeys.enabled" = true;
          };
          userChrome = ''
            #TabsToolbar
            {
              visibility: collapse;
            }
            #statuspanel[type="overLink"] #statuspanel-label
            #statuspanel[type="status"] #statuspanel-label[value^="Look"],
            #statuspanel[type="status"] #statuspanel-label[value^="Connect"],
            #statuspanel[type="status"] #statuspanel-label[value^="Send"],
            #statuspanel[type="status"] #statuspanel-label[value^="Transfer"],
            #statuspanel[type="status"] #statuspanel-label[value^="Read"],
            #statuspanel[type="status"] #statuspanel-label[value^="Wrote"],
            #statuspanel[type="status"] #statuspanel-label[value^="Wait"],
            #statuspanel[type="status"] #statuspanel-label[value*="TLS handshake"],
            #statuspanel[type="status"] #statuspanel-label[value*="FTP transaction"] {
            display:none!important;
            }
          '';
          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            consent-o-matic
            foxyproxy-standard
            floccus
            keepassxc-browser
            privacy-badger
            sponsorblock
            tree-style-tab
            tridactyl
            ublock-origin
          ];
        };
      };
    };
    rofi = {
      enable = true;
      font = "Hasklug Nerd Font 14";
      terminal = "kitty";
      theme = ./rofi-catppucin-mocha-theme.rasi;
      extraConfig = {
        modi = "drun,window";
        show-icons = true;
        drun-display-format = "{icon} {name}";
        location = 0;
        disable-history = false;
        hide-scrollbar = true;
        display-drun = "   Apps ";
        display-run = "   Run ";
        display-window = " 﩯  Window";
        display-Network = " 󰤨  Network";
        sidebar-mode = true;
      };
    };
    wezterm = {
      enable = false; # kind of buggy; can't start multiple windows
      package =
        let wrapper = pkgs.nixgl.nixGLIntel;
        in
        pkgs.writeShellScriptBin "wezterm" ''
          ${wrapper}/bin/nixGLIntel ${pkgs.wezterm}/bin/wezterm "$@"
        '';
      extraConfig = ''
        return {
          color_scheme = "Catppuccin Mocha",
          font = wezterm.font("Hasklug Nerd Font"),
          font_size = 14.0,
          enable_tab_bar = false,
        }
      '';

    };

    # kitty {{{2
    kitty = {
      enable = true;
      package =
        let wrapper = pkgs.nixgl.nixGLIntel;
        in
        pkgs.writeShellScriptBin "kitty" ''
          ${wrapper}/bin/nixGLIntel ${pkgs.kitty}/bin/kitty "$@"
        '';
      font = {
        name = "Hasklug Nerd Font";
        size = 14;
      };
      theme = "Catppuccin-Mocha";
      settings = {
        enable_audio_bell = false;
      };
    };
    alacritty = {
      enable = false;
      package =
        let wrapper = pkgs.nixgl.nixGLIntel;
        in
        pkgs.writeShellScriptBin "alacritty" ''
          ${wrapper}/bin/nixGLIntel ${pkgs.alacritty}/bin/alacritty "$@"
        '';
      settings = {
        window = {
          padding = {
            x = 2;
            y = 2;
          };
          decorations = "none";
          gtk_theme_variant = "dark";
        };
        font = {
          normal = {
            family = "Hasklug Nerd Font";
          };
          size = 14.0;
        };
        colors =
          let
            color = (import ../colors/saeparized.nix).color;
            normal = color.normal;
            bright = color.bright;
          in
          {
            inherit normal;
            inherit bright;
            primary = {
              background = color.background;
              foreground = color.foreground;
            };
            cursor = {
              text = color.background;
              cursor = color.foreground;
            };
            selection = {
              text = color.selectionForeground;
              background = color.selectionBackground;
            };
            cursor = {
              style = "Block";
              unfocused_hollow = true;
            };
            url = {
              launcher = {
                program = "xdg-open";
                args = [ ];
              };
              modifiers = "None";
            };
            mouse_bindings = [
              { mouse = "Middle"; action = "PasteSelection"; }
            ];
            key_bindings = [
              { key = "Key0"; mods = "Control|Alt"; action = "ResetFontSize"; }
              { key = "RBracket"; mods = "Control|Alt"; action = "IncreaseFontSize"; }
              { key = "LBracket"; mods = "Control|Alt"; action = "DecreaseFontSize"; }
            ];
          };
      };
    };
    ncmpcpp = {
      enable = true;
    };
    zathura = {
      enable = true;
      options = {

        # -*- mode: conf-space -*-

        # Based on, edited by me (saep):
        # Dark theme made in the spirit of 'alect-dark':
        # <https://github.com/alezost/alect-themes>.

        default-bg = "#1E1E1E";
        default-fg = "#D4D4CF";
        inputbar-bg = "#1E1E1E";
        inputbar-fg = "#D4D4CF";
        statusbar-bg = "#1E1E1E";
        statusbar-fg = "#D4D4CF";

        completion-bg = "#464646";
        completion-fg = "#d5d2be";
        completion-group-bg = "#464646";
        completion-group-fg = "#099709";
        completion-highlight-bg = "#6f6f6f";
        completion-highlight-fg = "#d5d2be";

        notification-bg = "#464646";
        notification-fg = "#f6f0e1";
        notification-warning-bg = "#464646";
        notification-warning-fg = "#e8e815";
        notification-error-bg = "#c64242";
        notification-error-fg = "#f6f0e1";

        index-bg = "#1E1E1E";
        index-fg = "#D4D4CF";
        index-active-bg = "#1E1E1E";
        index-active-fg = "#D4D4CF";

        recolor-lightcolor = "#1E1E1E";
        recolor-darkcolor = "#D4D4CF";
      };
    };
  };
  services = {
    mpd = {
      enable = true;
      musicDirectory = "${config.home.homeDirectory}/Music";
      extraConfig = ''
        audio_output {
          type "pulse"
          name "PA"
        }
      '';
    };
    mpdris2 = {
      enable = true;
      multimediaKeys = true;
    };
  };
}

