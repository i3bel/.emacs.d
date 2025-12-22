{ config, lib, ... } : {
  home.file = {
    ".config/emacs/assets/".source = ../assets;
    ".config/emacs/snippets".source = ../snippets;
  };

  home.sessionVariables.EMACSNATIVELOADPATH =
    let
      base = "${config.home.homeDirectory}/${config.programs.emacs-twist.directory}/eln-cache";
      parent = builtins.getEnv "EMACSNATIVELOADPATH";
    in "${base}:${parent}";

  home.activation.nativeCompileInit =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      emacs_bin="${config.programs.emacs-twist.wrapper}/bin/${config.programs.emacs-twist.name}"
      init_dir="${config.home.homeDirectory}/${config.programs.emacs-twist.directory}"
      cache_dir="$init_dir/eln-cache"

      if [ -x "$emacs_bin" ] && [ -d "$init_dir" ]; then
        # Replace symlinks with real files so comp uses a stable user path
        for f in init.el early-init.el; do
          if [ -e "$init_dir/$f" ]; then
            tmpfile=$(mktemp)
            cp -fL "$init_dir/$f" "$tmpfile"
            mv "$tmpfile" "$init_dir/$f"
          fi
        done

        mkdir -p "$cache_dir"
        find "$init_dir" -name '*.el' \
          -not -path "$cache_dir/*" \
          -not -path "$init_dir/transient/*" \
          -print0 |
          xargs -0 "$emacs_bin" --batch -Q \
            --eval "(setq native-compile-target-directory \"$cache_dir\")" \
            --eval "(setq native-comp-eln-load-path (list \"$cache_dir\"))" \
            -f batch-native-compile
      fi
    '';
}
