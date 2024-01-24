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

    neotest-src = {
      url = "github:nvim-neotest/neotest";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , nur
    , home-manager
    , nixgl
    , neotest-src
    } @inputs:
    let
      inherit (self) outputs;
      overlays = [
        nixgl.overlay
        nur.overlay
        (final: prev: {
          vimPlugins = prev.vimPlugins // {
            saep-neotest = final.vimUtils.buildVimPlugin {
              pname = "neotest";
              version = "HEAD";
              src = neotest-src;
            };
          };
        })
      ];
    in
    rec
    {
      home-manager-state-version = "22.05";
      color = (import ./colors/catppuccin/mocha.nix).color;
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = {
          allowUnFree = true;
        };
        overlays = overlays;
      };
      hmModules = {
        common = ./common.nix;
        nvim = ./nvim.nix;
        desktop = {
          common = ./desktop/common.nix;
          kde = ./desktop/kde.nix;
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
      homeConfigurations = {
        "saep@monoid" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = with hmModules; [
            common
            nvim
            desktop.common
            desktop.kde
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
        "saep@magma" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = with hmModules; [
            common
            desktop.common
            desktop.kde
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
            saepfigsDirectory = "git/saep/figs";
            # If the config needs attributes from a flake:
            # inherit flake;
            # then flake can be added to the arguments of e.g. home.nix
          };
        };
        "saep@swaep" = home-manager.lib.homeManagerConfiguration {
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
        "saep@nixos-wsl" = home-manager.lib.homeManagerConfiguration {
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
      nixosConfigurations = {
        magma = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs overlays; };
          modules = let username = "saep"; in [
            ./nixos/magma/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.users.saep = {
                home.username = username;
                home.homeDirectory = "/home/${username}";
                home.stateVersion = home-manager-state-version;
                imports = with hmModules ; [
                  common
                  desktop.common
                  desktop.kde
                  nvim
                  private
                  misc.syncthing
                ];
              };
              home-manager.extraSpecialArgs = {
                inherit pkgs;
                username = username;
                stateVersion = home-manager-state-version;
                color = color;
                isNixos = true;
                saepfigsDirectory = "git/${username}/figs";
              };
            }
          ];
        };
      };
    };
}
