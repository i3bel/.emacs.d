{ config, lib, ... } : {
  home.file = {
    "~/config/emacs/assets/banner.png".source = ../assets/banner.png;
    "~/config/emacs/assets/banner.txt".source = ../assets/banner.txt;
    "~/config/emacs/snippets".source = ../snippets;
  };

  home.activation = {  
    byteCompileInitEl = lib.hm.dag.entryAfter ["writeBoundary"] ''
      cd ${config.home.homeDirectory}/${config.programs.emacs-twist.directory}
      ${config.programs.emacs-twist.config}/bin/emacs --batch -f batch-byte-compile init.el  
    '';  
  }; 
}
