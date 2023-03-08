# Applications used on desktop computers and laptops
{ config, pkgs, lib, username, stateVersion, dpi, color, isNixos ? false, ... }:

let
  lock-screen =
    if isNixos then
      pkgs.writeShellScriptBin "lock-screen.sh" ''
        ${pkgs.xdotool}/bin/xdotool mousemove 0 0
        exec ${pkgs.i3lock}/bin/i3lock -c 1E1E1E
      ''
    else
      pkgs.writeShellScriptBin "lock-screen.sh" ''
        ${pkgs.xdotool}/bin/xdotool mousemove 0 0
        exec /usr/bin/i3lock -c 1E1E1E
      '';
  lock-screen-bin = "${lock-screen}/bin/lock-screen.sh";
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  # misc {{{1
  fonts.fontconfig.enable = true;
  home.language = {
    base = "en_US.UTF-8";
  };
  home.keyboard = {
    layout = "us";
    variant = "altgr-intl";
    options = [ "ctrl:nocaps" ];
  };
  qt = {
    enable = true;
    style.name = "adwaita-dark";
    style.package = pkgs.adwaita-dark;
  };

  # xdg {{{1
  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
    };
  };

  # configuration files {{{1
  xresources = let color = (import ../colors/saeparized.nix).color; in
    {
      properties = {
        # Xft settings
        "Xft*dpi" = dpi;
        "Xft*antialias" = true;
        "Xft*rgba" = "rgb";
        "Xft*hinting" = true;
        "Xft*hintstyle" = "hintslight";
        # Terminal settings
        "XTerm*utf8" = 1;
        "XTerm.termName" = "xterm-256color";
        "*.bellIsUrgent" = true;
        "*.saveLines" = 4096;
        "*.scrollTtyOutput" = false;
        "*.fastScroll" = true;
        ## Let the Meta (Alt) key send escape as other terminals do
        "*.metaSendsEscape" = true;

        # Font
        "*faceName" = "Hasklug Nerd Font Mono";
        "*faceSize" = 14;
        ## Face size for normal=;
        "*.VT100*faceSize" = 14;
        ## Face sizes for alternates=;
        ## Unreadable=;
        "*.VT100*faceSize1" = 10;
        ## Tiny=;
        "*.VT100*faceSize2" = 12;
        ## Small=;
        "*.VT100*faceSize3" = 14;
        ## Medium=;
        "*.VT100*faceSize4" = 16;
        ## Large=;
        "*.VT100*faceSize5" = 20;
        ## Huge=;
        "*.VT100*faceSize6" = 24;

        # A character class for URLs
        "*.charClass" = [ "33:48" "35-47:48" "58-59:48" "61:48" "63-64:48" "95:48" "126:48" ];

        # Color definitions
        "*background" = color.background;
        "*foreground" = color.foreground;
        "*fading" = "5";
        "*fadeColor" = color.normal.black;
        "*cursorColor" = color.normal.white;
        "*pointerColorBackground" = color.bright.blue;
        "*pointerColorForeGround" = color.bright.red;
        "*color0" = color.color0;
        "*color8" = color.color8;
        "*color1" = color.color1;
        "*color9" = color.color9;
        "*color2" = color.color2;
        "*color10" = color.color10;
        "*color3" = color.color3;
        "*color11" = color.color11;
        "*color4" = color.color4;
        "*color12" = color.color12;
        "*color5" = color.color5;
        "*color13" = color.color13;
        "*color6" = color.color6;
        "*color14" = color.color14;
        "*color7" = color.color7;
        "*color15" = color.color15;

        # Key bindings
        "*.scrollKey" = true;
        "*.alternateScroll" = true;
      };
      extraConfig =
        ''
          ! Keybindings:
          ! Copy/Paste with Ctrls-Shift-C/V
          ! Decrease/Increase font-size
          ! Clickable URLs
          *.VT100.translations: #override\n\
                  Shift Ctrl <KeyPress> v:insert-selection(CLIPBOARD)\n\
                  Shift Ctrl <KeyPress> c:select-set(CLIPBOARD)\n\
                  Shift Ctrl <Key> bracketleft: smaller-vt-font()\n\
                  Shift Ctrl <Key> bracketright: larger-vt-font()\n\
                  Meta <Btn1Up>: exec-formatted("xdg-open '%t'", PRIMARY)\n
        '';
    };

  # simple packages {{{1
  home.packages =
    let
      # Must use i3lock of debian system because pam files contains @include
      # statments and only debian-based systems use that...
      nixos-packages = if !isNixos then [ ] else with pkgs; [ i3lock ];
    in
    with pkgs;
    nixos-packages ++
    [
      lock-screen
      pkgs.nixgl.nixGLIntel
      keepassxc

      # window manager utilites
      alsa-utils
      autorandr
      brightnessctl
      feh
      hsetroot
      maim
      playerctl
      wmctrl
      xdg-utils
      xdotool
      xorg.iceauth
      xorg.setxkbmap
      xorg.xauth
      xorg.xprop
      xorg.xrdb
      xorg.xset
      xorg.xsetroot
      xsel
      xss-lock

      # other
      remmina

      # fonts
      (nerdfonts.override { fonts = [ "FiraCode" "Hasklig" "DroidSansMono" ]; })

      # keyboard flashing tool
      wally-cli
    ];

  # Programs {{{1
  programs = {
    # firefox {{{2
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
            "media.hardwaremediakeys.enabled" = false;
          };
          userChrome = ''
            #TabsToolbar
            {
              visibility: collapse;
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
    # wezterm {{{2
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
    # alacritty {{{2
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
    # ncmpcpp {{{2
    ncmpcpp = {
      enable = true;
    };
    # zathura {{{2
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
  # services {{{1
  services = {
    # sxhkd {{{2
    sxhkd = {
      enable = true;
      keybindings = {
        "XF86Audio{Prev,Next,Play}" = "playerctl {prevous,next,play-pause}";
        "XF86Audio{LowerVolume,RaiseVolume,Mute}" = "amixer -q sset Master {3%-,3%+,toggle}";
        "super + XF86Audio{Lower,Raise}Volume" = "playerctl {previous,next}";
        "super + XF86AudioMute" = "amixer sset Master toggle";
        "XF86MonBrightness{Up,Down}" = "brightnessctl set {5%-,5%+}";
        "ctrl + alt + l" = lock-screen-bin;
        "super + {BackSpace, backslash, bracketleft}" = "dunstctl {close-all, history-pop, context}";
      };
    };
    xsettingsd = {
      enable = true;
      settings = {
        "Net/EnableEventSounds" = 0;
        "Net/EnableInputFeedbackSounds" = 0;
        "Net/IconThemeName" = "Adwaita";
        "Net/ThemeName" = "Adwaita-dark";
        "Xft/DPI" = 147456;
        "Xft/Antialias" = 1;
        "Xft/HintStyle" = "hintslight";
        "Xft/Hinting" = 1;
        "Xft/RGBA" = "rgb";
      };
    };
    # udiskie {{{2
    udiskie = {
      enable = true;
      tray = "always";
    };
    # unclutter {{{2
    unclutter = {
      enable = true;
    };
    # mpd {{{2
    mpd = {
      enable = true;
      musicDirectory = "${config.home.homeDirectory}/Music";
    };
    # mpdris2 {{{2
    mpdris2 = {
      enable = true;
      multimediaKeys = true;
    };
    # dunst {{{2
    dunst = {
      enable = true;
      settings = {
        global = {
          font = "Hasklug Nerd Font 14";

          # The format of the message. Possible variables are:
          #   %a  appname
          #   %s  summary
          #   %b  body
          #   %i  iconname (including its path)
          #   %I  iconname (without its path)
          #   %p  progress value if set ([  0%] to [100%]) or nothing
          # Markup is allowed
          format = "<b>%s</b>\\n%b";

          # Sort messages by urgency
          sort = "yes";

          # Show how many messages are currently hidden (because of geometry)
          indicate_hidden = "yes";

          # alignment of message text.
          # Possible values are "left", "center" and "right"
          alignment = "left";

          # show age of message if message is older than show_age_threshold seconds.
          # set to -1 to disable
          show_age_threshold = 60;

          # split notifications into multiple lines if they don't fit into geometry
          word_wrap = "yes";

          # ignore newlines '\n' in notifications
          ignore_newline = "no";

          # The transparency of the window. range: [0; 100]
          # This option will only work if a compositing windowmanager is present (e.g. xcompmgr, compiz, etc..)
          transparency = 15;

          # Don't remove messages, if the user is idle (no mouse or keyboard input)
          # for longer than idle_threshold seconds.
          # Set to 0 to disable.
          idle_threshold = 120;

          # Which monitor should the notifications be displayed on.
          monitor = 0;

          # Display notification on focused monitor. Possible modes are:
          # mouse: follow mouse pointer
          # keyboard: follow window with keyboard focus
          # none: don't follow anything
          #
          # "keyboard" needs a windowmanager that exports the _NET_ACTIVE_WINDOW property.
          # This should be the case for almost all modern windowmanagers.
          #
          # If this option is set to mouse or keyboard, the monitor option will be
          # ignored.
          follow = "mouse";

          # should a notification popped up from history be sticky or
          # timeout as if it would normally do.
          sticky_history = "yes";

          # The height of a single line. If the height is smaller than the font height,
          # it will get raised to the font height.
          # This adds empty space above and under the text.
          line_height = 0;

          # Draw a line of 'separatpr_height' pixel height between two notifications.
          # Set to 0 to disable
          separator_height = 4;

          # padding between text and separator
          padding = 8;

          # horizontal padding
          horizontal_padding = 8;

          # Define a color for the separator.
          # possible values are:
          #  * auto: dunst tries to find a color fitting to the background
          #  * foreground: use the same color as the foreground
          #  * frame: use the same color as the frame.
          #  * anything else will be interpreted as a X color
          separator_color = "frame";

          # dmenu path
          dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst:";

          # browser for opening urls in context menu
          browser = "firefox";
        };

        urgency_low = {
          background = color.background;
          foreground = color.foreground;
          timeout = 10;
        };

        urgency_normal = {
          background = color.background;
          foreground = color.foreground;
          timeout = 10;
        };

        urgency_critical = {
          background = color.background;
          foreground = color.foreground;
          frame_color = color.Peach;
          timeout = 0;
        };
      };
    };
  };
  # xsession {{{1
  xsession = {
    enable = true;
    profileExtra = ''
      export PATH="$HOME/.nix-profile/bin:$PATH"

      xset s 900
      xss-lock --notifier="${lock-screen-bin}" --transfer-sleep-lock "${lock-screen-bin}" &

      eval $(ssh-agent)

      export GTK_THEME='Adwaita:dark'
      export QT_SCALE_FACTOR="0.5"
      [ -x $HOME/.fehbg ] && "$HOME/.fehbg"
      xrdb ${config.xresources.path}
    '';
    windowManager = {
      xmonad = {
        enable = true;
        extraPackages = with pkgs; haskellPackages: [
          haskellPackages.xmonad-contrib
          haskellPackages.megaparsec
          haskellPackages.relude
          haskellPackages.lens
          haskellPackages.pointedlist
          haskellPackages.generic-lens
          haskellPackages.hostname
        ];
        config = ./xmonad/Main.hs;
        libFiles = {
          "MyWorkspaces.hs" = ./xmonad/lib/MyWorkspaces.hs;
        };
      };
    };
  };
}

# vim: foldmethod=marker


