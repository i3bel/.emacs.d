{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.file = {
    ".config/emacs/assets/".source = ../assets;
    ".config/emacs/snippets".source = ../snippets;
  };

  home.packages = with pkgs; [
    #dotnet-sdk
    #omnisharp-roslyn
    nixd
    nodePackages.typescript-language-server
    rust-analyzer
    tree-sitter
  ];
}
