{ lib }:
with builtins;
{
  counsel = _: super: {
    files = removeAttrs super.files [
      "elpa.el"
      "ivy-avy.el"
      "ivy-faces.el"
      "ivy-hydra.el"
      "ivy-overlay.el"
      "ivy.el"
      "swiper.el"
    ];
  };
  multi-vterm = _: _: {
    # `multi-vterm.el` requires `vterm` at top-level, which triggers
    # an interactive prompt during batch byte-compilation.
    dontByteCompile = true;
  };
}
