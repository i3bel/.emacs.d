{
  description = "Kyure_A's Emacs";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    
    systems.url = "github:nix-systems/default";
    
    twist.url = "github:emacs-twist/twist.nix";
    
    org-babel.url = "github:emacs-twist/org-babel";

    elpa = {
      url = "git+https://git.savannah.gnu.org/git/emacs/elpa.git";
      flake = false;
    };
    
    melpa = {
      url = "github:melpa/melpa";
      flake = false;
    };
    
    nongnu = {
      url = "git+https://git.savannah.gnu.org/git/emacs/nongnu.git";
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
      systems,
      twist,
      ...
  } @ inputs:
    let
      supportedSystems = import systems;
      overlays = import ./nix/overlays.nix;
    in    
      flake-utils.lib.eachSystem supportedSystems
        (system: let
          inherit (nixpkgs) lib;

          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              inputs.org-babel.overlays.default
              overlays.emacs
            ];
          };

          inherit (inputs.emacs.packages.${system}) emacs emacs-git;

          profile = import ./default.nix {
            inherit pkgs;
            emacsPackage = emacs-git;
          };

          package = (inputs.twist.lib.makeEnv {
            inherit pkgs;
            inherit (profile) emacsPackage lockDir initFiles extraPackages;
            inputOverrides = (import ./nix/inputs.nix {inherit lib;}) // profile.extraInputOverrides;
            registries = (import ./nix/registries.nix inputs) ++ [
              {
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
            ];
          };
                    
          apps = package.makeApps {
            lockDirName = ./lock;
          };
        });
}
