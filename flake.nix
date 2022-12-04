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
    saep-lazygit = {
      url = "github:saep/lazygit/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # neovim plugins that are either not in nix or for which I want to follow a
    # specific branch
    saeparized-vim = {
      url = "github:saep/saeparized-vim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    saep-nvim-unception = {
      url = "github:saep/nvim-unception/nix-flake";
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
    , saep-lazygit
    , saep-nvim-unception
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
          saep-lazygit.overlay.x86_64-linux
          saep-nvim-unception.overlay
        ];
      };
    in
    {
      pkgs = pkgs;
      color = color;
      home-manager = home-manager;
      hmModules = {
        common = ./common.nix;
        desktop = ./desktop/desktop.nix;
        dev = {
          java = ./dev/java.nix;
        };
        syncthing = ./misc/syncthing.nix;
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
          isNixos = true;
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
          ./misc/syncthing.nix
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
        modules = [
          ./common.nix
          ./private.nix
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
