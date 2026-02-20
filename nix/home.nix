{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.emacs-twist;

  dockApp = pkgs.runCommandLocal "emacs-app" { } ''
    app="$out/Applications/Emacs.app"
    sourceApp="${cfg.config.emacs}/Applications/Emacs.app"
    mkdir -p "$out/Applications"

    if [ -d "$sourceApp" ]; then
      cp -R "$sourceApp" "$app"
      chmod -R u+w "$app"
    else
      mkdir -p "$app/Contents/MacOS"
      cat > "$app/Contents/Info.plist" <<'EOF'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>CFBundleName</key>
        <string>Emacs</string>
        <key>CFBundleIdentifier</key>
        <string>com.kyurea.emacs</string>
        <key>CFBundleExecutable</key>
        <string>Emacs</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
      </dict>
    </plist>
    EOF
    fi

    rm -f "$app/Contents/MacOS/Emacs"
    cat > "$app/Contents/MacOS/Emacs" <<EOF
    #!${pkgs.runtimeShell}
    exec "${cfg.config.emacs}/bin/emacsclient" -n -c -a "${cfg.wrapper}/bin/${cfg.name}"
    EOF

    chmod +x "$app/Contents/MacOS/Emacs"
  '';
in
{
  home.file = {
    ".config/emacs/assets/".source = ../assets;
    ".config/emacs/snippets".source = ../snippets;
  }
  // lib.optionalAttrs pkgs.stdenv.isDarwin {
    "Applications/Emacs.app" = {
      source = "${dockApp}/Applications/Emacs.app";
      recursive = true;
    };
  };

  home.packages =
    with pkgs;
    [
      #dotnet-sdk
      #omnisharp-roslyn
      nixd
      nodePackages.typescript-language-server
      rust-analyzer
      tree-sitter
    ]
    # `libvterm` in nixpkgs is Linux-only. On Darwin, Emacs `vterm` also uses
    # `libvterm-neovim`, so include that package instead.
    ++ lib.optional pkgs.stdenv.isLinux libvterm
    ++ lib.optional pkgs.stdenv.isDarwin libvterm-neovim;
}
