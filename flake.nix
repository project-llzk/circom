{
  inputs = {
    llzk-pkgs.url = "github:project-llzk/llzk-nix-pkgs";
    nixpkgs.follows = "llzk-pkgs/nixpkgs";
    flake-utils.follows = "llzk-pkgs/flake-utils";
    llzk-rs-pkgs = {
      url = "git+https://github.com/project-llzk/llzk-rs";
      inputs = {
        nixpkgs.follows = "llzk-pkgs/nixpkgs";
        flake-utils.follows = "llzk-pkgs/flake-utils";
        llzk-pkgs.follows = "llzk-pkgs";
      };
    };
    llzk-lib.follows = "llzk-rs-pkgs/llzk-lib";
    release-helpers.follows = "llzk-rs-pkgs/llzk-lib/release-helpers";
    rust-overlay.follows = "llzk-rs-pkgs/rust-overlay";
  };

  # Custom colored bash prompt
  nixConfig.bash-prompt = "\\[\\e[0;32m\\][circom]\\[\\e[m\\] \\[\\e[38;5;244m\\]\\w\\[\\e[m\\] % ";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      release-helpers,
      llzk-pkgs,
      llzk-lib,
      llzk-rs-pkgs,
      rust-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import rust-overlay)
            llzk-pkgs.overlays.default
            llzk-lib.overlays.default
            llzk-rs-pkgs.overlays.default
            release-helpers.overlays.default
          ];
        };

        # Lit tests need FileCheck but directly adding the LLVM `bin` dir to the path causes
        # linking problems in `llzk-sys`. Instead, create a symlink in a new directory for the path.
        createFileCheckSymlink = ''
          mkdir -p $PWD/build-tools
          ln -sf "${pkgs.llzk-llvmPackages.llvm}/bin/FileCheck" $PWD/build-tools/FileCheck
          ln -sf "${pkgs.llzk}/bin/llzk-opt" $PWD/build-tools/llzk-opt
          export PATH="$PWD/build-tools:$PATH"
        '';
      in
      {
        packages = flake-utils.lib.flattenTree {
          default = pkgs.rustPlatform.buildRustPackage (
            {
              pname = "circom-to-llzk";
              version = "0.1.0";
              src = ./.;

              nativeBuildInputs = pkgs.llzkSharedEnvironment.nativeBuildInputs;
              buildInputs = pkgs.llzkSharedEnvironment.devBuildInputs;
              cargoLock = {
                lockFile = ./Cargo.lock;
                allowBuiltinFetchGit = true;
              };

              cargoBuildFlags = [
                "--package"
                "circom"
              ];
              cargoTestFlags = [
                "--package"
                "circom"
              ];
              preBuild = createFileCheckSymlink;
            }
            // pkgs.llzkSharedEnvironment.env
            // pkgs.llzkSharedEnvironment.pkgSettings
          );
        };

        devShells = flake-utils.lib.flattenTree {
          default = pkgs.mkShell (
            {
              nativeBuildInputs = pkgs.llzkSharedEnvironment.nativeBuildInputs;
              buildInputs = pkgs.llzkSharedEnvironment.devBuildInputs ++ [
                pkgs.rust-bin.stable.latest.default
              ];

              shellHook = ''
                ## Bail out of pipes where any command fails
                set -uo pipefail
                ${createFileCheckSymlink}
                echo "Welcome to the circom-to-llzk devshell!"
              '';
            }
            // pkgs.llzkSharedEnvironment.env
            // pkgs.llzkSharedEnvironment.devSettings
          );
        };
      }
    );
}
