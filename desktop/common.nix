# Applications used on desktop computers and laptops
{
  config,
  pkgs,
  username,
  stateVersion,
  saepfigsDirectory,
  isNixos ? false,
  ...
}:
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
      defaultApplications = {
        "text/*" = "nvim.desktop";
        "text/plain" = "nvim.desktop";
        "application/json" = "nvim.desktop";
        "applications/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "text/html" = "firefox.desktop";
        "x-scheme-handler/file" = "pcmanfm-qt.desktop";
        "inode/directory" = "pcmanfm-qt.desktop";
      };
    };
    systemDirs = {
      data = [ "/home/${username}/.nix-profile/share" ];
    };
    desktopEntries = {
      whatsapp = {
        name = "Whatsapp";
        exec = "${pkgs.chromium}/bin/chromium --app=https://web.whatsapp.com";
        terminal = false;
        icon = "chromium-browser";
      };
      youtube = {
        name = "Youtube";
        exec = "${pkgs.chromium}/bin/chromium --app=https://youtube.com";
        terminal = false;
        icon = "chromium-browser";
      };
    };
    configFile."ghostty".source =
      config.lib.file.mkOutOfStoreSymlink "/home/${username}/${saepfigsDirectory}/config/ghostty";
  };

  home.packages =
    with pkgs;
    let
      optNixGL = if isNixos then [ ] else [ pkgs.nixgl.nixGLIntel ];
    in
    optNixGL
    ++ [

      keepassxc
      chromium

      xdg-utils

      pcmanfm-qt

      # other
      remmina
      pavucontrol

      # fonts
      pkgs.nerd-fonts.fira-code
      pkgs.nerd-fonts.hasklug
      pkgs.nerd-fonts.droid-sans-mono
    ];

  programs = {
    chromium = {
      enable = true;
      package = pkgs.chromium;
      extensions = [
        { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
        { id = "oboonakemofpalcgghocfoadofidjkkk"; } # keepassxc-browser
        { id = "bkkmolkhemgaeaeggcmfbghljjjoofoh"; } # catppuccin mocha
        { id = "alageihdeogmjlkgifaeefodfbdbljjf"; } # auto high quality youtube
        { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # sponsorblock for youtube
        { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # plasma integration
      ];
    };
    firefox = {
      enable = true;
      profiles = {
        default = {
          id = 0;
          settings = {
            "browser.aboutConfig.showWarning" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.search.suggest.enabled" = false; # they are terrible for advanced users
            "browser.startup.page" = 3; # restore previous tabs and windows
            "browser.urlbar.placeholderName" = "DuckDuckGo";
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
            "media.hardwaremediakeys.enabled" = true;
            "sidebar.verticalTabs" = true;
            "sidebar.main.tools" = "";
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
            darkreader
            foxyproxy-standard
            floccus
            keepassxc-browser
            privacy-badger
            sponsorblock
            vimium
            ublock-origin
          ];
        };
      };
    };
    # kitty {{{2
    kitty = {
      enable = true;
      package =
        if isNixos then
          pkgs.kitty
        else
          let
            wrapper = pkgs.nixgl.nixGLIntel;
          in
          pkgs.writeShellScriptBin "kitty" ''
            ${wrapper}/bin/nixGLIntel ${pkgs.kitty}/bin/kitty "$@"
          '';
      font = {
        name = "Hasklug Nerd Font";
        size = 14;
      };
      settings = {
        enable_audio_bell = false;
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
