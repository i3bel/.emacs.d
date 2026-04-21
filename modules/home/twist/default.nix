{ inputs, flake, ... }:
{ lib, pkgs, ... }:
{
  imports = [
    inputs.twist.homeModules.emacs-twist
  ];

  programs.emacs-twist = {
    config = lib.mkDefault flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
    earlyInitFile = lib.mkDefault flake.earlyInitEl.${pkgs.stdenv.hostPlatform.system};
    createManifestFile = lib.mkDefault true;
  };

  home.file = {
    ".config/emacs/assets/".source = ../../../assets;
    ".config/emacs/snippets".source = ../../../snippets;
  };

  home.packages =
    with pkgs;
    [
      clang-tools
      cmake
      gcc
      libtool
      nixd
      nodePackages.typescript-language-server
      rust-analyzer
      tree-sitter
    ]
    # `libvterm` in nixpkgs is Linux-only. On Darwin, Emacs `vterm` also uses
    # `libvterm-neovim`, so include that package instead.
    ++ lib.optional pkgs.stdenv.isLinux libvterm
    ++ lib.optional pkgs.stdenv.isDarwin libvterm-neovim;
}
