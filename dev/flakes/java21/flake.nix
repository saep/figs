{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in
    {
      devShells."x86_64-linux".default = pkgs.mkShell {
        buildInputs = with pkgs; [
          jdk21
          # maven
          # gradle
        ];

        nativeBuildInputs = with pkgs; [
          pkg-config
        ];
        env.JAVA_HOME = "${pkgs.jdk21}/lib/openjdk";
      };
    };
}
