# CLAUDE.md

nf-icon builds a freedesktop icon theme from the Nerd Fonts glyphs.
[README.md](README.md) covers usage.

## Layout

- `flake.nix` defines `lib.mkNerdIconTheme`. `packages.default` is that
  function called with the default palette.
- `build.py` runs inside the derivation. It reads the font and writes the SVGs.

## Rules

- The derivation builds the whole theme from the Symbols Nerd Font in `pkgs`.
  Never commit generated SVGs. Never add a manual step or one that writes into
  the checkout.
- Glyph names come from the font. Do not add a separate name table.
- `mkNerdIconTheme` uses only the `pkgs` it is given. The flake's own nixpkgs
  exists for `packages.default`.
- Icon names end in the colour, as in `nf-fa-book-red`. Icons are looked up by
  name alone, so one glyph in two colours needs two names.

## Checking a change

Run both commands, then format Nix with `alejandra` and Python with `black`.

```bash
nix build
nix flake check
```
