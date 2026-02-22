{
  description = "Kyure_A's Emacs";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    twist.url = "github:Kyure-A/twist.nix";

    org-babel.url = "github:Kyure-A/org-babel";

    elpa = {
      url = "github:elpa-mirrors/elpa";
      flake = false;
    };

    melpa = {
      url = "github:melpa/melpa";
      flake = false;
    };

    nongnu = {
      url = "github:elpa-mirrors/nongnu";
      flake = false;
    };

    epkgs = {
      url = "github:emacsmirror/epkgs";
      flake = false;
    };

    emacs.url = "github:nix-community/emacs-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      emacs,
      ...
    }@inputs:
    let
      overlays = import ./nix/overlays.nix;
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        inherit (nixpkgs) lib;

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            inputs.org-babel.overlays.default
            emacs.overlay
            overlays.emacs
          ];
        };

        profile = import ./default.nix {
          inherit pkgs;
        };

        package = (
          inputs.twist.lib.makeEnv {
            inherit pkgs;
            inherit (profile)
              emacsPackage
              lockDir
              initFiles
              extraPackages
              ;
            inputOverrides = (import ./nix/inputs.nix { inherit lib; }) // profile.extraInputOverrides;
            registries = (import ./nix/registries.nix inputs);
          }
        );

        earlyInitEl = profile.earlyInitFile;

      in
      {
        packages.default = package;

        earlyInitEl = earlyInitEl;

        homeModules.twist =
          { lib, ... }:
          {
            imports = [
              inputs.twist.homeModules.emacs-twist
              ./nix/home.nix
            ];

            programs.emacs-twist = {
              config = lib.mkDefault package;
              earlyInitFile = lib.mkDefault earlyInitEl;
              createManifestFile = lib.mkDefault true;
            };
          };

        apps = package.makeApps {
          lockDirName = "lock";
        };

        formatter = pkgs.writeShellApplication {
          name = "fmt";
          runtimeInputs = [
            pkgs.treefmt
            pkgs.nixfmt-rfc-style
          ];
          text = ''
            set -euo pipefail
            root="''${PRJ_ROOT:-$(pwd)}"
            exec treefmt --config-file "$root/treefmt.toml" --tree-root "$root" "$@"
          '';
        };
      }
    );
}
