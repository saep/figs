{
  description = "saep's Home Manager flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # nixpkgs.url = "git+file:///home/saep/git/nixpkgs";
    nur = {
      url = "github:nix-community/NUR";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
    };
    neogit = {
      url = "github:NeogitOrg/neogit";
      flake = false;
    };
    one-small-step-for-vimkind = {
      url = "github:jbyuki/one-small-step-for-vimkind";
      flake = false;
    };
    snacks = {
      url = "github:folke/snacks.nvim";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nur,
      home-manager,
      nixgl,
      catppuccin,
      neogit,
      one-small-step-for-vimkind,
      snacks,
    }@inputs:
    let
      inherit (self) outputs;
      overlays = [
        nixgl.overlay
        nur.overlays.default
        (self: super: {
          remmina = super.remmina.overrideAttrs (prev: {
            version = "ecb29e7830037dd3ee618472c80b5e8eaecf1ce0";
            src = super.fetchFromGitLab {
              owner = "Remmina";
              repo = "Remmina";
              rev = "ecb29e7830037dd3ee618472c80b5e8eaecf1ce0";
              hash = "sha256-u+ysAFi7I7nXIiAw7VCmHbqgtRoZgkPnRfy/Mnl1b2g=";
            };
          });
          vimPlugins = super.vimPlugins // {
            neogit = super.vimUtils.buildVimPlugin {
              name = "neogit";
              src = neogit;
            };
            one-small-step-for-vimkind = super.vimUtils.buildVimPlugin {
              name = "one-small-step-for-vimkind";
              src = one-small-step-for-vimkind;
            };
            nvim-treesitter-nu = super.vimUtils.buildVimPlugin {
              name = "nvim-treesitter-nu";
              src = super.tree-sitter-grammars.tree-sitter-nu.src;
            };
            snacks = super.vimUtils.buildVimPlugin {
              name = "snacks";
              src = snacks;
            };
          };
        })
      ];
    in
    rec {
      home-manager-state-version = "22.05";
      hm = home-manager;
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
        "saep@swaep" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = with hmModules; [
            catppuccin.homeManagerModules.catppuccin
            common
            nvim
            desktop.common
            private
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
      };
      nixosConfigurations = {
        magma = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs overlays;
          };
          modules =
            let
              username = "saep";
            in
            [
              ./nixos/magma/configuration.nix
              catppuccin.nixosModules.catppuccin
              home-manager.nixosModules.home-manager
              {
                home-manager.users.saep = {
                  home.username = username;
                  home.homeDirectory = "/home/${username}";
                  home.stateVersion = home-manager-state-version;
                  imports = with hmModules; [
                    catppuccin.homeManagerModules.catppuccin
                    common
                    desktop.common
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
