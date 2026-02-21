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
    iconSource="${cfg.config.emacs}/Applications/Emacs.app/Contents/Resources/Emacs.icns"

    mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"

    if [ ! -f "$iconSource" ]; then
      echo "Missing Emacs icon file: $iconSource" >&2
      exit 1
    fi
    cp "$iconSource" "$app/Contents/Resources/Emacs.icns"

    cat > "$app/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>CFBundleName</key>
    <string>Emacs</string>
    <key>CFBundleDisplayName</key>
    <string>Emacs</string>
    <key>CFBundleIdentifier</key>
    <string>moe.kyre.emacs</string>
    <key>CFBundleExecutable</key>
    <string>Emacs</string>
    <key>CFBundleIconFile</key>
    <string>Emacs.icns</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>NSHighResolutionCapable</key>
    <true/>
  </dict>
</plist>
EOF

    printf 'APPL????' > "$app/Contents/PkgInfo"

    cat > "$app/Contents/MacOS/Emacs" <<EOF
#!${pkgs.runtimeShell}
export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"
exec "${cfg.wrapper}/bin/${cfg.name}" "\$@"
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

  home.activation.refreshEmacsAppRegistration = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      app="$HOME/Applications/Emacs.app"
      if [ -d "$app" ]; then
        /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app" >/dev/null 2>&1 || true
        /usr/bin/touch "$app" || true
      fi
    ''
  );

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
