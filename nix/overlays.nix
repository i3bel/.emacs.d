{
  emacs = (final : prev: {
    emacs = prev.emacs.override {
      withNativeCompilation = true;
    };
    emacs-git = prev.emacs-git.override {
      withNativeCompilation = true;
    };
  });
}
