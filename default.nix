{
  pkgs,
  emacsPackage ? pkgs.emacs-git,
}:
let
  kuroModule = import ./packages/kuro { inherit pkgs; };
in
{
  emacsPackage = emacsPackage;
  lockDir = ./lock;
  initFiles = [
    (pkgs.tangleOrgBabelFile "init.el" ./README.org { })
  ];
  earlyInitFile = (pkgs.tangleOrgBabelFile "early-init.el" ./early-init.org { });
  exportManifest = true;
  extraPackages = [ ];
  extraSiteStartElisp = ''
    (setenv "KURO_MODULE_PATH" "${kuroModule}/lib")
  '';
  extraRecipeDir = ./recipes;
  extraInputOverrides = { };
}
