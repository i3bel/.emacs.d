{
  description = "Kyure_A's Emacs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    inputs:
    let
      overlays = import ./overlays.nix;
      overlaysList = [
        inputs.org-babel.overlays.default
        inputs.emacs.overlay
        overlays.emacs
      ];
      outputs = inputs.blueprint {
        inherit inputs;
        nixpkgs.overlays = overlaysList;
      };
      inherit (inputs.nixpkgs) lib;
    in
    outputs
    // {
      apps = lib.mapAttrs (
        _system: packages:
        packages.default.makeApps {
          lockDirName = "lock";
        }
      ) (lib.filterAttrs (_: packages: packages ? default) outputs.packages);

      earlyInitEl = lib.mapAttrs (
        system: _:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = overlaysList;
          };
          profile = import ./default.nix {
            inherit pkgs;
          };
        in
        profile.earlyInitFile
      ) outputs.packages;
    };
}
