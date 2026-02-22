{ inputs, flake, ... }:
{ lib, pkgs, ... }:
let
  profile = import ../../../default.nix {
    inherit pkgs;
  };
in
{
  imports = [
    inputs.twist.homeModules.emacs-twist
    ./emacs-home.nix
  ];

  programs.emacs-twist = {
    config = lib.mkDefault flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
    earlyInitFile = lib.mkDefault profile.earlyInitFile;
    createManifestFile = lib.mkDefault true;
  };
}
