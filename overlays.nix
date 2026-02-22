let
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);
  emacsInput = lock.nodes.emacs.locked;
  emacsOverlaySrc = builtins.fetchTree {
    type = emacsInput.type;
    owner = emacsInput.owner;
    repo = emacsInput.repo;
    rev = emacsInput.rev;
    narHash = emacsInput.narHash;
  };
  emacsMasterMeta = builtins.fromJSON (
    builtins.readFile (emacsOverlaySrc + "/repos/emacs/emacs-master.json")
  );
  emacsMirrorFetch =
    (builtins.removeAttrs emacsMasterMeta [
      "type"
      "version"
    ])
    // {
      url = "https://github.com/emacs-mirror/emacs.git";
    };
in
{
  emacs = (
    final: prev: {
      emacs = prev.emacs.override {
        withNativeCompilation = false;
      };
      emacs-git =
        (prev.emacs-git.override {
          withNativeCompilation = false;
        }).overrideAttrs
          (_: {
            src = prev.fetchgit emacsMirrorFetch;
          });
    }
  );
}
