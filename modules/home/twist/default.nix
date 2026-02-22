{ inputs, flake, ... }:
{ lib, pkgs, ... }:
{
  imports = [
    inputs.twist.homeModules.emacs-twist
    ./emacs-home.nix
  ];

  programs.emacs-twist = {
    config = lib.mkDefault flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
    earlyInitFile = lib.mkDefault flake.earlyInitEl.${pkgs.stdenv.hostPlatform.system};
    createManifestFile = lib.mkDefault true;
  };
}
