{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    naersk.url = "github:nix-community/naersk";
  };

  outputs =
    {
      self,
      nixpkgs,
      naersk,
    }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      naerskLib = pkgs.callPackage naersk { };
    in
    {
      devShells."x86_64-linux".default = pkgs.mkShell {
        buildInputs = with pkgs; [
          bacon
          bunyan-rs
          cargo
          cargo-edit
          cargo-nextest
          clippy
          comrak
          rust-analyzer
          rustc
        ];

        nativeBuildInputs = with pkgs; [
          pkg-config
          libiconv
          openssl
        ];
        env.RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
      };
      packages."x86_64-linux".default = naerskLib.buildPackage {
        src = ./.;
        nativeBuildInputs = with pkgs; [
          pkg-config
          libiconv
          openssl
        ];
      };
    };
}
