{
  description = "saep's Home Manager flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nur
    , home-manager
    , nixgl
    }:
    let hm = home-manager;
    in
    rec
    {
      home-manager-state-version = "22.05";
      home-manager = hm;
      color = (import ./colors/cattpuccin/mocha.nix).color;
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          nixgl.overlay
          nur.overlay
        ];
      };
      hmModules = {
        common = ./common.nix;
        nvim = ./nvim.nix;
        desktop = {
          common = ./desktop/common.nix;
          xcape = ./desktop/xcape.nix;
          xmonad = ./desktop/xmonad.nix;
        };
        dev = {
          java = ./dev/java.nix;
        };
        misc = {
          syncthing = ./misc/syncthing.nix;
        };
        private = ./private.nix;
      };

      # configuration for personal computers
      homeConfigurations."saep@monoid" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = with hmModules; [
          common
          nvim
          desktop.common
          desktop.xmonad
          private
          misc.syncthing
        ];
        extraSpecialArgs = {
          username = "saep";
          stateVersion = home-manager-state-version;
          /* dpi = 96; */
          dpi = 144;
          color = color;
          isNixos = true;
          # If the config needs attributes from a flake:
          # inherit flake;
          # then flake can be added to the arguments of e.g. home.nix
        };
      };
      homeConfigurations."saep@magma" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = with hmModules; [
          common
          desktop.common
          nvim
          private
          misc.syncthing
        ];
        extraSpecialArgs = {
          username = "saep";
          stateVersion = home-manager-state-version;
          /* dpi = 96; */
          dpi = 144;
          color = color;
          isNixos = true;
          # If the config needs attributes from a flake:
          # inherit flake;
          # then flake can be added to the arguments of e.g. home.nix
        };
      };
      homeConfigurations."saep@swaep" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = with hmModules; [
          common
          nvim
          desktop.common
          desktop.xmonad
          private
          desktop.xcape
          misc.syncthing
        ];
        extraSpecialArgs = {
          username = "saep";
          stateVersion = home-manager-state-version;
          dpi = 96;
          color = color;
          isNixos = false;
        };
      };
      homeConfigurations."saep@nixos-wsl" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = with hmModules; [
          common
          nvim
          private
        ];
        extraSpecialArgs = {
          username = "saep";
          stateVersion = home-manager-state-version;
          color = color;
          isNixos = true;
        };
      };
    };
}
