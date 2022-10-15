{
  description = "saep's Home Manager flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xmonad = {
      url = "github:xmonad/xmonad";
      inputs.unstable.follows = "nixpkgs";
    };
    xmonad-contrib = {
      url = "github:xmonad/xmonad-contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # neovim plugins that are either not in nix or for which I want to follow a
    # specific branch
    saeparized-vim = {
      url = "github:saep/saeparized-vim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nur
    , home-manager
    , nixgl
    , saeparized-vim
    , xmonad
    , xmonad-contrib
    }:
    let
      color = (import ./colors/cattpuccin/mocha.nix).color;
      home-manager-state-version = "22.05";
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          nixgl.overlay
          nur.overlay
          saeparized-vim.overlay
          xmonad.overlay
          xmonad-contrib.overlay
        ];
      };
    in
    {
      pkgs = pkgs;
      home-manager = home-manager;
      hmModules = {
        common = ./common.nix;
        desktop = ./desktop/desktop.nix;
        dev = {
          java = ./dev/java.nix;
        };
      };
      # configuration for personal computers
      homeConfigurations."saep@monoid" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./common.nix ./desktop/desktop.nix ./private.nix ];
        extraSpecialArgs = {
          username = "saep";
          stateVersion = home-manager-state-version;
          /* dpi = 96; */
          dpi = 144;
          color = color;
          # If the config needs attributes from a flake:
          # inherit flake;
          # then flake can be added to the arguments of e.g. home.nix
        };
      };
      homeConfigurations."saep@swaep" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./common.nix
          ./desktop/desktop.nix
          ./private.nix
          ./desktop/xcape.nix
        ];
        extraSpecialArgs = {
          username = "saep";
          stateVersion = home-manager-state-version;
          dpi = 96;
          color = color;
        };
      };
      homeConfigurations."saep@nixos-wsl" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./common.nix
          ./private.nix
        ];
        extraSpecialArgs = {
          username = "saep";
          stateVersion = home-manager-state-version;
          color = color;
        };
      };
    };
}
