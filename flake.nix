{
  description = "playdate-rust-template";

  inputs = {
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crank = {
      url = "github:pd-rs/crank";
      flake = false;
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      perSystem = { config, inputs', pkgs, system, ... }: {
        _module.args.pkgs =
          import inputs.nixpkgs {
            localSystem = system;
            overlays = [
              (_: _: { crane = inputs.crane.lib.${system}; })
              inputs.fenix.overlays.default
              (final: prev: {
                crank = final.crane.buildPackage {
                  src = inputs.crank;
                  buildInputs = final.lib.optionals final.stdenv.isDarwin [
                    final.libiconv
                  ];
                };
              })
            ];
          };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.crank
            pkgs.fenix.latest.cargo
            pkgs.fenix.latest.clippy
            pkgs.fenix.latest.rustc
            pkgs.fenix.latest.rustfmt
          ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            pkgs.gcc-arm-embedded
          ];
        };
      };
    };
}
