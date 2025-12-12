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
  extraPackages = ["claude-code"];
  extraRecipeDir = ./recipes;
  extraInputOverrides = {};
}
