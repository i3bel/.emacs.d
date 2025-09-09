{
  description = "Kyure_A's Emacs";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    
    twist.url = "github:emacs-twist/twist.nix";
    
    org-babel.url = "github:emacs-twist/org-babel";

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

  outputs = {
    self,
      nixpkgs,
      flake-utils,
      emacs,
      ...
  } @ inputs:
    let
      overlays = import ./nix/overlays.nix;
    in    
      flake-utils.lib.eachDefaultSystem
        (system: let
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
            emacsPackage = pkgs.emacs-git;
          };

          package = (inputs.twist.lib.makeEnv {
            inherit pkgs;
            inherit (profile) emacsPackage lockDir initFiles earlyInitFile extraPackages;
            inputOverrides = (import ./nix/inputs.nix {inherit lib;}) // profile.extraInputOverrides;
            registries = (import ./nix/registries.nix inputs) ++ [
              {
		            name = "custom";
                type = "melpa";
                path = profile.extraRecipeDir;
              }
            ];
          });
          
        in {
          packages.default = package;

          homeModules.twist = {
            imports = [
              inputs.twist.homeModules.emacs-twist
              ./nix/home.nix
            ];
          };
          
          apps = package.makeApps {
            lockDirName = "lock";
          };
        });
}
