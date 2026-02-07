{
  pkgs,
  inputs,
  overlays,
  ...
}:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot = {
    # Enable BBR congestion control
    kernelModules = [ "tcp_bbr" ];
    kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
    # default is fq_codel
    kernel.sysctl."net.core.default_qdisc" = "fq"; # see https://news.ycombinator.com/item?id=14814530
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
    };

    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        enableCryptodisk = true;
      };
    };
  };

  networking.hostName = "magma";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  time.timeZone = "Europe/Berlin";

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "de_DE.UTF-8";
    };
  };
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  services.earlyoom = {
    enable = true;
  };
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
  };
  services.ratbagd.enable = true; # piper mouse

  security.sudo-rs = {
    enable = true;
    extraRules = [
      {
        groups = [
          "users"
          "libvirtd"
        ];
        commands = [
          {
            command = "/run/current-system/sw/bin/headsetcontrol";
            options = [ "NOPASSWD" ];
          }
        ];
      }
      {
        users = [ "saep" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
  services.udev.extraRules = ''
    ACTION!="add|change", GOTO="headset_end"
      
    # Logitech G930
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0a1f", TAG+="uaccess"
      
    # Logitech G633/G635/G933/G935
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0a5c", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0a89", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0a5b", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0a87", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0ab5", TAG+="uaccess"
      
    LABEL="headset_end"

    # Keymapp Flashing rules for the Voyager
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"

    # Disable Voyager as joystick input, so that I don't have to unplug it to play Sekiro
    # with my Controller.
    SUBSYSTEM=="input", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1977", ENV{ID_INPUT_JOYSTICK}="" 
  '';

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  catppuccin.sddm.enable = true;

  # Enable the Plasma 5 Desktop Environment.
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    defaultSession = "plasma";
    autoLogin = {
      enable = false;
      user = "saep";
    };
  };
  services.desktopManager = {
    plasma6.enable = true;
    cosmic.enable = true;
  };

  services.system76-scheduler.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
    options = "ctrl:nocaps";
  };

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  hardware = {
    bluetooth = {
      enable = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
    keyboard.zsa.enable = true;
    steam-hardware.enable = true;
    xpadneo.enable = true;
  };

  programs = {
    kdeconnect.enable = true;
    dconf.enable = true;
    gamemode.enable = true;
    localsend.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    virt-manager.enable = true;
  };

  users.users.saep = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.bash;
    packages = with pkgs; [
      kdePackages.kdeplasma-addons
      kdePackages.kcolorchooser

    ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = overlays;
  environment = {
    pathsToLink = [ "/share/bash-completion" ];
    systemPackages = with pkgs; [
      (catppuccin-kde.override { flavour = [ "mocha" ]; })
      dive # look into docker images
      podman-tui
      podman-compose
      headsetcontrol
      lsof
      mangohud
      piper
      usbutils
      wineWowPackages.staging
      winetricks
      wl-clipboard
    ];
  };

  services.openssh.enable = true;

  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    8384
    22000 # syncthing
  ];
  networking.firewall.allowedUDPPorts = [
    22000
    21027 # syncthing
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  virtualisation = {
    libvirtd.enable = false;
    containers.enable = true;
    podman = {
      enable = true;
      # docker alias
      dockerCompat = true;
      # Required so that podman-compose containers can talk to each other
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # Config is version controlled.
  system.copySystemConfiguration = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
