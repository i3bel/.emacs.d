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
    (let ((cxx-tools-bin "${pkgs.lib.makeBinPath [ pkgs.clang-tools pkgs.gcc ]}"))
      (setenv "PATH" (concat cxx-tools-bin path-separator (getenv "PATH")))
      (dolist (dir (reverse (split-string cxx-tools-bin path-separator t)))
        (add-to-list 'exec-path dir)))
    (setenv "KURO_MODULE_PATH" "${kuroModule}/lib")
  '';
  extraRecipeDir = ./recipes;
  extraInputOverrides = { };
}
