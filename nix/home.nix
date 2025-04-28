{ config, lib, ... } : {
  home.file = {
    ".config/emacs/assets/".source = ../assets;
    ".config/emacs/snippets".source = ../snippets;
  };

  home.activation = {
  byteCompileInitEl = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cd ${config.home.homeDirectory}/${config.programs.emacs-twist.directory}

      ${config.programs.emacs-twist.config}/bin/emacs --batch \
      --eval "(setq package-enable-at-startup t)" \
      --eval "(package-initialize)" \
      --eval "(require 'use-package)" \
      --eval "(eval-and-compile
                  (setopt use-package-ensure-function #'(lambda (&rest args) t))
                  (setopt use-package-always-defer t)
                  (setopt use-package-compute-statistics t))" \
      -f batch-byte-compile init.el
  '';
};
}
