{
  pkgs,
  emacsPackage,
}: {
  inherit emacsPackage;
  lockDir = ./lock;
  initFiles = [
    (pkgs.tangleOrgBabelFile "init.el" ./init.org {})
  ];
  earlyInitFile = [
    (pkgs.tangleOrgBabelFile "early-init.el" ./early-init.org {})
  ];
  exportManifest = true;
  extraPackages = [];
  extraRecipeDir = ./recipes;
  extraInputOverrides = {};
}
