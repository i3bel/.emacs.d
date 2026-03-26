{ pkgs, inputs, ... }:
let
  inherit (pkgs) lib;

  profile = import ../../default.nix {
    inherit pkgs;
  };
in
inputs.twist.lib.makeEnv {
  inherit pkgs;
  inherit (profile)
    emacsPackage
    lockDir
    initFiles
    extraPackages
    extraSiteStartElisp
    ;
  inputOverrides = (import ./input-overrides.nix { inherit lib; }) // profile.extraInputOverrides;
  registries = import ./registries.nix inputs;
}
