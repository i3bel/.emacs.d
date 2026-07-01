{
  runCommandLocal,
  writeShellScriptBin,
}:

emacsEnv:
let
  initFile = runCommandLocal "twist-init.el" { } ''
    mkdir -p "$out"
    touch "$out/init.el"
    for file in ${builtins.concatStringsSep " " emacsEnv.initFiles}; do
      cat "$file" >> "$out/init.el"
      echo >> "$out/init.el"
    done
  '';
in
writeShellScriptBin "emacs-twist" ''
  set -eu

  initdir="$(mktemp -d "''${TMPDIR:-/tmp}/emacs-twist-XXX")"
  cleanup() {
    rm -rf "$initdir"
  }
  trap cleanup EXIT

  ln -s ${initFile}/init.el "$initdir/init.el"
  ln -s ${emacsEnv.earlyInitFile} "$initdir/early-init.el"

  ${emacsEnv}/bin/emacs --init-directory="$initdir" "$@"
''
