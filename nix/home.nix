{ config, lib, ... } : {
  home.file = {
    "~/config/emacs/assets/banner.png".source = ../assets/banner.png;
    "~/config/emacs/assets/banner.txt".source = ../assets/banner.txt;
    "~/config/emacs/snippets".source = ../snippets;
  };
}
