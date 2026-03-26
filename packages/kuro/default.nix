{ pkgs }:
let
  lock = builtins.fromJSON (builtins.readFile ../../lock/flake.lock);
  kuroLocked = lock.nodes.kuro.locked;
  kuroSrc = builtins.fetchTree {
    type = kuroLocked.type;
    owner = kuroLocked.owner;
    repo = kuroLocked.repo;
    rev = kuroLocked.rev;
    narHash = kuroLocked.narHash;
  };
  sharedLibrary = pkgs.stdenv.hostPlatform.extensions.sharedLibrary;
in
pkgs.rustPlatform.buildRustPackage {
  pname = "kuro-core";
  version = "1.0.0";

  src = kuroSrc;
  cargoLock.lockFile = kuroSrc + "/Cargo.lock";

  buildInputs = if pkgs.stdenv.isDarwin then [ pkgs.libiconv ] else [ ];

  cargoBuildFlags = [
    "--package"
    "kuro-core"
  ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    module="$(find target -path "*/release/libkuro_core${sharedLibrary}" | head -n 1)"
    if [[ -z "$module" ]]
    then
      echo "Failed to find built kuro module in target/" >&2
      exit 1
    fi

    install -Dm755 "$module" "$out/lib/libkuro_core${sharedLibrary}"

    runHook postInstall
  '';
}
