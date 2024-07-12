{
  description = "Application packaged using poetry2nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication;
      in
      {
        packages = {
          wemod-launcher = mkPoetryApplication {
            projectDir = self;
            preferWheels = true;
#            overrides = poetry2nix.defaultPoetryOverrides.extend
#              (final: prev: {
#                freesimplegui = prev.freesimplegui.overridePythonAttrs (old: {
#                  buildInputs = old.buildInputs ++ [ prev.setuptools ];
#                });
#              });
          };
          default = self.packages.${system}.wemod-launcher;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.wemod-launcher ];
        };

        devShells.poetry = pkgs.mkShell {
          packages = [ pkgs.poetry ];
        };
      });
}