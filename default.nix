{
  pkgs,
  emacsPackage,
}: {
  emacsPackage = pkgs.emacs-git;
  lockDir = ./lock;
  initFiles = [
    (pkgs.tangleOrgBabelFile "init.el" ./README.org {})
  ];
  earlyInitFile = (pkgs.tangleOrgBabelFile "early-init.el" ./early-init.org {});
  exportManifest = true;
  extraPackages = [ ];
  extraRecipeDir = ./recipes;
  extraInputOverrides = {};
}
