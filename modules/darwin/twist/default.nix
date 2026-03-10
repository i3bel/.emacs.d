{ flake, ... }:
{ lib, pkgs, ... }:
let
  emacsPackage = flake.packages.${pkgs.stdenv.hostPlatform.system}.default;

  dockApp = pkgs.runCommandLocal "emacs-app" { } ''
    app="$out/Applications/Emacs.app"
    iconSource="${emacsPackage}/Applications/Emacs.app/Contents/Resources/Emacs.icns"

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
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"
exec "${emacsPackage}/bin/emacs" "\$@"
EOF

    chmod +x "$app/Contents/MacOS/Emacs"
  '';
in
{
  system.activationScripts.postActivation.text = lib.mkAfter ''
    app_source="${dockApp}/Applications/Emacs.app"
    app_target="/Applications/Emacs.app"

    rm -rf "$app_target"
    cp -R "$app_source" "$app_target"
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app_target" >/dev/null 2>&1 || true
    /usr/bin/touch "$app_target" || true
  '';
}
