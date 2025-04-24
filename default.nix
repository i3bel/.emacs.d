{
  pkgs,
  emacsPackage,
}: {
  inherit emacsPackage;
  lockDir = ./lock;
  initFiles = [
    (pkgs.tangleOrgBabelFile "init.el" ./README.org {})
  ];
  extraPackages = [
    # sitawo komento hazusuto ugokanai
    # "usePackage"
    # "pairable"
    # "readable"
    # "readable-typo-theme"
    # "readable-mono-theme"
  ];
  extraRecipeDir = ./recipes;
  extraInputOverrides = {};
}
