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
    (let ((clangd-bin "${pkgs.lib.makeBinPath [ pkgs.clang-tools ]}"))
      (setenv "PATH" (concat clangd-bin path-separator (getenv "PATH")))
      (add-to-list 'exec-path clangd-bin))
    (setenv "KURO_MODULE_PATH" "${kuroModule}/lib")
  '';
  extraRecipeDir = ./recipes;
  extraInputOverrides = { };
}
