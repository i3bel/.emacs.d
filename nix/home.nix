{ config, lib, ... } : {
  home.file = {
    ".config/emacs/assets/".source = ../assets;
    ".config/emacs/snippets".source = ../snippets;
  };

  home.activation = {
    byteCompileInitEl = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${config.programs.emacs-twist.config}/bin/emacs --batch \
      --load init.el \
      -f batch-byte-compile ${config.home.homeDirectory}/.config/emacs/init.el
  '';
  };
}
