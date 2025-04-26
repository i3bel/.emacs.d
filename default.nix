{
  pkgs,
  emacsPackage,
}: {
  inherit emacsPackage;
  lockDir = ./lock;
  initFiles = [
    (pkgs.tangleOrgBabelFile "init.el" ./README.org {})
  ];
  exportManifest = true;
  extraPackages = [];
  extraRecipeDir = ./recipes;
  extraInputOverrides = {};
}
